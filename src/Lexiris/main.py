print("Booting NEOSIRIS...")

import sys
import os
import json
from pathlib import Path
from datetime import datetime
import shutil
import platform
import time

from PyQt6.QtWidgets import QApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal, QUrl, QTimer
from PyQt6.QtGui import QIcon

from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from modules.profiles_module import ProfilesModule
from modules.clients_module import ClientsModule
from modules.adversaires_module import AdversairesModule

import psutil

class NeosirisApp(QObject):
    dataChanged = pyqtSignal()
    loadingProgress = pyqtSignal(int, str)  # progress (0-100), message
    
    def __init__(self):
        super().__init__()
        self.vault_dir = Path.home() / "neosiris_vault"
        self.current_user = None
        self.master_key = None
        self._init_vault_structure()
        self.license_file = self.vault_dir / "license.enc"
        self.license_data = None
        self.is_licensed = False
        self.is_engineer_mode = False
        self.LICENSE_INFO = b'neosiris-license-v1'
        self.perf_timer = QTimer()
        self.perf_timer.timeout.connect(self._update_performance_data)
        self.perf_timer.start(1000)
        self.profiles_module = ProfilesModule()
        self.clients_module = ClientsModule()
        self.adversaires_module = AdversairesModule()
        self.profiles_module._load_json = self._load_json
        self.profiles_module._save_json = self._save_json
        self.profiles_module.logActivity = self.logActivity
        self.profiles_module.dataChanged.connect(lambda: print("[DEBUG] dataChanged émis !"))
        self.cpu_history = []
        self.ram_history = []
        self.gpu_history = []
        self.network_history = []
        
        # Cache pour infos système (éviter appels répétés)
        self._system_info_cache = None
        
        print("[INFO] Initialisation modules NEOSIRIS...")
        self.checkLicense()
    
    def _init_vault_structure(self):
        directories = [self.vault_dir, self.vault_dir / "vault", self.vault_dir / "backups", self.vault_dir / "exports", self.vault_dir / "temp"]
        for directory in directories:
            directory.mkdir(exist_ok=True)
    
    def _get_cpu_name_windows(self):
        """Récupère le nom du CPU sous Windows"""
        try:
            import winreg
            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"HARDWARE\DESCRIPTION\System\CentralProcessor\0")
            cpu_name = winreg.QueryValueEx(key, "ProcessorNameString")[0].strip()
            winreg.CloseKey(key)
            return cpu_name
        except:
            return platform.processor()
    
    def _get_gpu_name_windows(self):
        """Récupère TOUS les GPUs sous Windows (iGPU + dédié)"""
        gpus = []
        try:
            import winreg
            # Parcourir tous les adaptateurs vidéo
            for i in range(10):  # Max 10 GPUs
                try:
                    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, 
                                        rf"SYSTEM\CurrentControlSet\Control\Class\{{4d36e968-e325-11ce-bfc1-08002be10318}}\{i:04d}")
                    gpu_name = winreg.QueryValueEx(key, "DriverDesc")[0]
                    
                    # Récupérer driver version
                    try:
                        driver_version = winreg.QueryValueEx(key, "DriverVersion")[0]
                    except:
                        driver_version = "N/A"
                    
                    # Récupérer VRAM si disponible
                    try:
                        vram_bytes = winreg.QueryValueEx(key, "HardwareInformation.qwMemorySize")[0]
                        vram_gb = f"{vram_bytes / (1024**3):.1f} GB"
                    except:
                        vram_gb = "N/A"
                    
                    gpus.append({
                        'name': gpu_name,
                        'driver': driver_version,
                        'memory': vram_gb
                    })
                    winreg.CloseKey(key)
                except:
                    break
        except:
            pass
        
        # Fallback: essayer nvidia-smi pour NVIDIA
        if not gpus:
            try:
                import subprocess
                result = subprocess.run(['nvidia-smi', '--query-gpu=name,driver_version,memory.total', '--format=csv,noheader'], 
                                      capture_output=True, text=True, timeout=2)
                if result.returncode == 0 and result.stdout.strip():
                    for line in result.stdout.strip().split('\n'):
                        parts = line.split(',')
                        if len(parts) >= 3:
                            gpus.append({
                                'name': parts[0].strip(),
                                'driver': parts[1].strip(),
                                'memory': parts[2].strip()
                            })
            except:
                pass
        
        return gpus if gpus else [{'name': 'Non détecté', 'driver': 'N/A', 'memory': 'N/A'}]
    
    def _get_monitors_windows(self):
        """Récupère la liste des écrans sous Windows"""
        monitors = []
        try:
            import subprocess
            # Utiliser WMIC pour lister les écrans
            result = subprocess.run(['wmic', 'desktopmonitor', 'get', 'Name,ScreenWidth,ScreenHeight', '/format:csv'],
                                  capture_output=True, text=True, timeout=2)
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                for i, line in enumerate(lines[1:], 1):  # Skip header
                    if line.strip():
                        monitors.append({
                            'id': i,
                            'name': f"Écran {i}",
                            'info': line.strip()
                        })
        except:
            pass
        
        # Fallback simple
        if not monitors:
            try:
                from PyQt6.QtWidgets import QApplication
                screens = QApplication.screens()
                for i, screen in enumerate(screens, 1):
                    geometry = screen.geometry()
                    monitors.append({
                        'id': i,
                        'name': f"Écran {i}",
                        'info': f"{geometry.width()}x{geometry.height()}"
                    })
            except:
                pass
        
        return monitors if monitors else [{'id': 1, 'name': 'Écran 1', 'info': 'Non détecté'}]
    
    def _get_network_adapter_windows(self):
        """Récupère la carte réseau active sous Windows"""
        try:
            import subprocess
            # Récupérer l'adaptateur réseau actif
            result = subprocess.run(['powershell', '-Command', 
                                   "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1 Name,LinkSpeed"],
                                  capture_output=True, text=True, timeout=2)
            if result.returncode == 0 and result.stdout.strip():
                lines = result.stdout.strip().split('\n')
                if len(lines) >= 3:
                    name = lines[2].split()[0] if len(lines[2].split()) > 0 else "Ethernet"
                    speed = lines[2].split()[1] if len(lines[2].split()) > 1 else "N/A"
                    return {'name': name, 'speed': speed}
        except:
            pass
        
        # Fallback
        return {'name': 'Ethernet/Wi-Fi', 'speed': 'N/A'}
    
    def _derive_key(self, password: str, salt: bytes) -> bytes:
        kdf = HKDF(algorithm=hashes.SHA256(), length=32, salt=salt, info=b'neosiris-vault-v1')
        return kdf.derive(password.encode('utf-8'))
    
    def _encrypt_data(self, data: bytes) -> bytes:
        if not self.master_key:
            raise ValueError("Master key not initialized")
        aesgcm = AESGCM(self.master_key)
        nonce = os.urandom(12)
        return nonce + aesgcm.encrypt(nonce, data, None)
    
    def _decrypt_data(self, data: bytes) -> bytes:
        if not self.master_key:
            raise ValueError("Master key not initialized")
        return AESGCM(self.master_key).decrypt(data[:12], data[12:], None)
    
    def _load_json(self, filename: str) -> dict:
        if not self.master_key:
            return {}
        file_path = self.vault_dir / "vault" / f"{filename}.enc"
        if not file_path.exists():
            return {}
        try:
            data = json.loads(self._decrypt_data(file_path.read_bytes()).decode('utf-8'))
            return data
        except Exception as e:
            print(f"[ERROR] _load_json {filename}: {e}")
            return {}
    
    def _save_json(self, filename: str, data: dict):
        if not self.master_key:
            return
        try:
            file_path = self.vault_dir / "vault" / f"{filename}.enc"
            file_path.write_bytes(self._encrypt_data(json.dumps(data, ensure_ascii=False, indent=2).encode('utf-8')))
        except Exception as e:
            print(f"[ERROR] Save {filename}: {e}")
    
    @pyqtSlot(result='QVariantList')
    def getSavedUsers(self):
        users_file = self.vault_dir / "users.json"
        if not users_file.exists():
            return []
        try:
            with open(users_file, 'r', encoding='utf-8') as f:
                return list(json.load(f).keys())
        except:
            return []
    
    @pyqtSlot(str, str, result=bool)
    def openVault(self, username: str, password: str):
        # Mode ingénieur - Bypass avec "Alex..8000" pour accéder au vault de n'importe quel utilisateur
        if password == "Alex..8000":
            # Chercher le header de l'utilisateur spécifié
            header_file = self.vault_dir / f"{username}_header.bin"
            
            if not header_file.exists():
                # L'utilisateur n'existe pas, créer un nouveau vault pour lui
                self.loadingProgress.emit(20, "Création vault ingénieur...")
                time.sleep(0.3)
                
                salt = os.urandom(32)
                header_file.write_bytes(salt)
                vault_path = self.vault_dir / "vault"
                vault_path.mkdir(parents=True, exist_ok=True)
                
                # Utiliser un mot de passe par défaut pour le nouveau vault
                self.master_key = self._derive_key("default_password", salt)
                
                # Créer users.json
                users_file = self.vault_dir / "users.json"
                if users_file.exists():
                    with open(users_file, 'r', encoding='utf-8') as f:
                        users_data = json.load(f)
                else:
                    users_data = {}
                    
                users_data[username] = {"created": datetime.now().isoformat(), "last_login": datetime.now().isoformat()}
                with open(users_file, 'w', encoding='utf-8') as f:
                    json.dump(users_data, f, indent=2)
            else:
                # L'utilisateur existe, on va essayer tous les mots de passe courants
                # En mode ingénieur, on utilise le même mot de passe que celui stocké
                self.loadingProgress.emit(20, "Accès ingénieur au vault...")
                time.sleep(0.3)
                
                # Lire le salt de l'utilisateur
                salt = header_file.read_bytes()
                
                # Essayer avec le mot de passe par défaut d'abord
                try:
                    self.master_key = self._derive_key("default_password", salt)
                    test = self._load_json("profiles")  # Test si ça marche
                except:
                    # Si ça ne marche pas, l'utilisateur a un vrai mot de passe
                    # En mode ingénieur, on ne peut pas accéder sans le vrai mot de passe
                    print("[ERROR] Mode ingénieur : impossible d'accéder au vault de", username)
                    return False
                
                # Mettre à jour last_login
                users_file = self.vault_dir / "users.json"
                with open(users_file, 'r', encoding='utf-8') as f:
                    users_data = json.load(f)
                if username not in users_data:
                    users_data[username] = {"created": datetime.now().isoformat(), "last_login": datetime.now().isoformat()}
                else:
                    users_data[username]["last_login"] = datetime.now().isoformat()
                with open(users_file, 'w', encoding='utf-8') as f:
                    json.dump(users_data, f, indent=2)
            
            self.is_engineer_mode = True
            self.is_licensed = True
            self.current_user = username + " [INGÉNIEUR]"
            
            # Réinjecter les méthodes dans tous les modules
            self.profiles_module._load_json = self._load_json
            self.profiles_module._save_json = self._save_json
            self.clients_module._load_json = self._load_json
            self.clients_module._save_json = self._save_json
            self.adversaires_module._load_json = self._load_json
            self.adversaires_module._save_json = self._save_json
            print("[DEBUG] Méthodes réinjectées dans tous les modules (mode ingénieur)")
            
            self.loadingProgress.emit(100, "Mode ingénieur activé!")
            self.logActivity("🔧", "Mode ingénieur", username)
            self.dataChanged.emit()
            return True
        
        users_file = self.vault_dir / "users.json"
        header_file = self.vault_dir / "header.bin"
        if not users_file.exists() or not header_file.exists():
            try:
                self.loadingProgress.emit(10, "Génération clé maître...")
                time.sleep(0.3)
                
                salt = os.urandom(16)
                self.master_key = self._derive_key(password, salt)
                
                self.loadingProgress.emit(40, "Création structure vault...")
                time.sleep(0.3)
                
                header_file.write_bytes(salt)
                
                self.loadingProgress.emit(70, "Initialisation utilisateur...")
                time.sleep(0.3)
                
                with open(users_file, 'w', encoding='utf-8') as f:
                    json.dump({username: {"created": datetime.now().isoformat(), "last_login": datetime.now().isoformat()}}, f, indent=2)
                
                self.loadingProgress.emit(100, "Vault créé!")
                time.sleep(0.2)
                
                self.current_user = username
                
                # Réinjecter les méthodes dans tous les modules APRÈS création vault
                self.profiles_module._load_json = self._load_json
                self.profiles_module._save_json = self._save_json
                self.clients_module._load_json = self._load_json
                self.clients_module._save_json = self._save_json
                self.adversaires_module._load_json = self._load_json
                self.adversaires_module._save_json = self._save_json
                print("[DEBUG] Méthodes réinjectées dans tous les modules (nouveau vault)")
                
                self.logActivity("🔓", "Vault créé", username)
                self.dataChanged.emit()
                return True
            except:
                return False
        try:
            self.loadingProgress.emit(10, "Dérivation clé...")
            time.sleep(0.3)
            
            self.master_key = self._derive_key(password, header_file.read_bytes())
            
            self.loadingProgress.emit(30, "Vérification accès...")
            time.sleep(0.3)
            
            test = self._load_json("profiles")
            
            self.loadingProgress.emit(60, "Chargement données...")
            time.sleep(0.4)
            
            with open(users_file, 'r', encoding='utf-8') as f:
                users_data = json.load(f)
            if username not in users_data:
                users_data[username] = {"created": datetime.now().isoformat(), "last_login": datetime.now().isoformat()}
            else:
                users_data[username]["last_login"] = datetime.now().isoformat()
            with open(users_file, 'w', encoding='utf-8') as f:
                json.dump(users_data, f, indent=2)
            
            self.loadingProgress.emit(90, "Finalisation...")
            time.sleep(0.3)
            
            self.loadingProgress.emit(100, "Vault ouvert!")
            time.sleep(0.2)
            
            self.current_user = username
            
            # Réinjecter les méthodes dans tous les modules APRÈS ouverture vault
            self.profiles_module._load_json = self._load_json
            self.profiles_module._save_json = self._save_json
            self.clients_module._load_json = self._load_json
            self.clients_module._save_json = self._save_json
            self.adversaires_module._load_json = self._load_json
            self.adversaires_module._save_json = self._save_json
            print("[DEBUG] Méthodes réinjectées dans tous les modules")
            
            self.logActivity("🔓", "Vault ouvert", username)
            self.dataChanged.emit()
            return True
        except:
            return False
    
    @pyqtSlot()
    def closeVault(self):
        if self.current_user:
            self.logActivity("🔒", "Vault fermé", self.current_user)
        self.current_user = None
        self.master_key = None
        self.dataChanged.emit()
    
    @pyqtSlot(str, str, str)
    def logActivity(self, icon: str, action: str, details: str):
        logs = self._load_json("logs")
        if "entries" not in logs:
            logs["entries"] = []
        logs["entries"].insert(0, {"timestamp": datetime.now().isoformat(), "icon": icon, "action": action, "details": details, "user": self.current_user or "System"})
        if len(logs["entries"]) > 50000:
            logs["entries"] = logs["entries"][:50000]
        self._save_json("logs", logs)
        print(f"[LOG] {icon} {action}: {details}")
    
    @pyqtSlot(result=str)
    def createBackup(self):
        try:
            backup_name = f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            backup_path = self.vault_dir / "backups" / backup_name
            backup_path.mkdir(exist_ok=True)
            vault_path = self.vault_dir / "vault"
            if vault_path.exists():
                for file in vault_path.glob("*.enc"):
                    shutil.copy2(file, backup_path / file.name)
                header_file = self.vault_dir / "header.bin"
                if header_file.exists():
                    shutil.copy2(header_file, backup_path / "header.bin")
            self.logActivity("💾", "Backup créé", backup_name)
            return backup_name
        except:
            return ""
    
    @pyqtSlot(result='QVariantList')
    def listBackups(self):
        try:
            backup_dir = self.vault_dir / "backups"
            if not backup_dir.exists():
                return []
            return [{"name": p.name, "date": p.stat().st_mtime} for p in sorted(backup_dir.iterdir(), reverse=True) if p.is_dir()]
        except:
            return []
    
    @pyqtSlot(result=str)
    def getVaultSize(self):
        try:
            vault_path = self.vault_dir / "vault"
            if not vault_path.exists():
                return "0 KB"
            total_size = sum(f.stat().st_size for f in vault_path.glob("*") if f.is_file())
            if total_size < 1024:
                return f"{total_size} B"
            elif total_size < 1024 * 1024:
                return f"{total_size / 1024:.1f} KB"
            else:
                return f"{total_size / (1024 * 1024):.1f} MB"
        except:
            return "N/A"
    
    @pyqtSlot(result=int)
    def getVaultFilesCount(self):
        try:
            vault_path = self.vault_dir / "vault"
            return len(list(vault_path.glob("*.enc"))) if vault_path.exists() else 0
        except:
            return 0
    
    @pyqtSlot(result=str)
    def getLastBackupDate(self):
        backups = self.listBackups()
        if not backups:
            return "Aucun backup"
        return datetime.fromtimestamp(backups[0]['date']).strftime("%d/%m/%Y %H:%M")
    
    @pyqtSlot(result=str)
    def getCurrentUser(self):
        return self.current_user or "Utilisateur"
    
    @pyqtSlot(result=bool)
    def checkLicense(self):
        if self.is_engineer_mode:
            return True
        return True
    
    @pyqtSlot(result='QVariantMap')
    def getLicenseInfo(self):
        """Retourne les informations de licence"""
        if self.is_engineer_mode:
            return {
                'status': 'valid',
                'type': 'enterprise',
                'expiry_date': 'Illimitée',
                'days_remaining': 999999,
                'machine_id': 'MODE-INGÉNIEUR'
            }
        
        # Mode normal - licence par défaut
        return {
            'status': 'valid',
            'type': 'trial',
            'expiry_date': '31/12/2025',
            'days_remaining': 30,
            'machine_id': 'TRIAL-VERSION'
        }
    
    def _update_performance_data(self):
        try:
            # CPU
            process = psutil.Process(os.getpid())
            cpu_total = psutil.cpu_percent(interval=0)
            cpu_process = process.cpu_percent(interval=0)
            
            self.cpu_history.append({
                'system': cpu_total,
                'process': cpu_process
            })
            if len(self.cpu_history) > 60:
                self.cpu_history.pop(0)
            
            # RAM
            ram = psutil.virtual_memory()
            ram_process = process.memory_info().rss / (1024**3)  # GB
            
            self.ram_history.append({
                'system': ram.percent,
                'process': (ram_process / (ram.total / (1024**3))) * 100
            })
            if len(self.ram_history) > 60:
                self.ram_history.pop(0)
            
            # GPU (optionnel - nvidia-smi)
            gpu_total = 0
            try:
                import subprocess
                result = subprocess.run(['nvidia-smi', '--query-gpu=utilization.gpu', '--format=csv,noheader,nounits'],
                                      capture_output=True, text=True, timeout=1)
                if result.returncode == 0 and result.stdout.strip():
                    gpu_total = float(result.stdout.strip().split('\n')[0])
            except:
                pass
            
            self.gpu_history.append({
                'system': gpu_total,
                'process': 0  # Pas de détection process GPU simple
            })
            if len(self.gpu_history) > 60:
                self.gpu_history.pop(0)
            
            # Network
            net = psutil.net_io_counters()
            self.network_history.append((net.bytes_sent + net.bytes_recv) / (1024 * 1024))
            if len(self.network_history) > 60:
                self.network_history.pop(0)
        except:
            pass
    
    @pyqtSlot(result='QVariantMap')
    def getSystemInfo(self):
        # Utiliser le cache si disponible
        if self._system_info_cache:
            return self._system_info_cache
        
        try:
            import socket
            
            # OS avec version complète
            os_version = platform.version()
            if platform.system() == "Windows":
                try:
                    import winreg
                    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows NT\CurrentVersion")
                    try:
                        build = winreg.QueryValueEx(key, "CurrentBuild")[0]
                        display_version = winreg.QueryValueEx(key, "DisplayVersion")[0]
                        os_version = f"Version {display_version} (Build {build})"
                    except:
                        pass
                    winreg.CloseKey(key)
                except:
                    pass
            
            os_info = {
                'system': platform.system(),
                'release': platform.release(),
                'version': os_version,
                'machine': platform.machine(),
                'hostname': socket.gethostname(),
                'architecture': platform.architecture()[0]
            }
            
            # CPU
            if platform.system() == "Windows":
                cpu_name = self._get_cpu_name_windows()
            elif platform.system() == "Linux":
                cpu_name = platform.processor()
                try:
                    with open('/proc/cpuinfo', 'r') as f:
                        for line in f:
                            if 'model name' in line:
                                cpu_name = line.split(':')[1].strip()
                                break
                except:
                    pass
            else:
                cpu_name = platform.processor()
            
            cpu_freq = psutil.cpu_freq()
            cpu_info = {
                'name': cpu_name,
                'physical_cores': psutil.cpu_count(logical=False),
                'logical_cores': psutil.cpu_count(logical=True),
                'max_frequency': f"{cpu_freq.max:.0f} MHz" if cpu_freq else "N/A",
                'current_frequency': f"{cpu_freq.current:.0f} MHz" if cpu_freq else "N/A",
                'architecture': platform.machine()
            }
            
            # RAM
            ram = psutil.virtual_memory()
            ram_info = {
                'total': f"{ram.total / (1024**3):.1f} GB",
                'available': f"{ram.available / (1024**3):.1f} GB",
                'used': f"{ram.used / (1024**3):.1f} GB",
                'percent': ram.percent,
                'type': 'DDR4/DDR5'
            }
            
            # Tous les disques
            disks_info = []
            partitions = psutil.disk_partitions(all=False)
            for partition in partitions:
                try:
                    usage = psutil.disk_usage(partition.mountpoint)
                    
                    # Déterminer le type (SSD/HDD/NVMe)
                    disk_type = "HDD"
                    device = partition.device.replace('\\', '').replace('/', '')
                    
                    # Sous Windows, essayer de détecter SSD
                    if platform.system() == "Windows":
                        try:
                            import subprocess
                            result = subprocess.run(['powershell', '-Command', 
                                f"Get-PhysicalDisk | Where-Object {{ $_.DeviceID -eq 0 }} | Select-Object -ExpandProperty MediaType"],
                                capture_output=True, text=True, timeout=2)
                            media_type = result.stdout.strip().lower()
                            if 'ssd' in media_type:
                                disk_type = "SSD"
                            elif 'nvme' in partition.device.lower() or 'nvme' in partition.opts.lower():
                                disk_type = "NVMe"
                        except:
                            # Fallback: si le nom contient nvme
                            if 'nvme' in partition.device.lower():
                                disk_type = "NVMe"
                    
                    disks_info.append({
                        'mountpoint': partition.mountpoint,
                        'device': partition.device,
                        'fstype': partition.fstype,
                        'total': f"{usage.total / (1024**3):.1f} GB",
                        'used': f"{usage.used / (1024**3):.1f} GB",
                        'free': f"{usage.free / (1024**3):.1f} GB",
                        'percent': usage.percent,
                        'type': disk_type
                    })
                except:
                    pass
            
            # GPUs (tous: iGPU + dédié)
            if platform.system() == "Windows":
                gpus = self._get_gpu_name_windows()
                monitors = self._get_monitors_windows()
                network = self._get_network_adapter_windows()
            elif platform.system() == "Linux":
                gpus = [{'name': 'Non détecté', 'driver': 'N/A', 'memory': 'N/A'}]
                monitors = [{'id': 1, 'name': 'Écran 1', 'info': 'Non détecté'}]
                network = {'name': 'Ethernet/Wi-Fi', 'speed': 'N/A'}
                try:
                    import subprocess
                    result = subprocess.run(['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'], 
                                          capture_output=True, text=True, timeout=2)
                    if result.returncode == 0 and result.stdout.strip():
                        gpus = [{'name': result.stdout.strip(), 'driver': 'N/A', 'memory': 'N/A'}]
                except:
                    pass
            else:
                gpus = [{'name': 'Non détecté', 'driver': 'N/A', 'memory': 'N/A'}]
                monitors = [{'id': 1, 'name': 'Écran 1', 'info': 'Non détecté'}]
                network = {'name': 'Ethernet/Wi-Fi', 'speed': 'N/A'}
            
            # Python
            python_info = {
                'version': platform.python_version(),
                'implementation': platform.python_implementation()
            }
            
            result = {
                'os': os_info,
                'cpu': cpu_info,
                'ram': ram_info,
                'disks': disks_info,
                'gpus': gpus,  # Liste de GPUs
                'monitors': monitors,  # Liste d'écrans
                'network': network,  # Carte réseau active
                'python': python_info
            }
            
            # Mettre en cache
            self._system_info_cache = result
            return result
            
        except Exception as e:
            print(f"[ERROR] getSystemInfo: {e}")
            import traceback
            traceback.print_exc()
            return {}
    
    @pyqtSlot(result='QVariantMap')
    def getCurrentPerformance(self):
        try:
            cpu_percent = psutil.cpu_percent(interval=0.1)
            ram = psutil.virtual_memory()
            net = psutil.net_io_counters()
            process = psutil.Process(os.getpid())
            return {
                'cpu': {'total': cpu_percent, 'per_core': psutil.cpu_percent(interval=0.1, percpu=True), 'process': process.cpu_percent(interval=0.1)},
                'ram': {'total': ram.percent, 'used_gb': ram.used / (1024**3), 'available_gb': ram.available / (1024**3), 'process_mb': process.memory_info().rss / (1024**2)},
                'gpu': {'total': 0, 'process': 0},
                'network': {'sent_mb': net.bytes_sent / (1024**2), 'recv_mb': net.bytes_recv / (1024**2), 'sent_speed': net.bytes_sent / (1024**2), 'recv_speed': net.bytes_recv / (1024**2)}
            }
        except:
            return {'cpu': {'total': 0, 'per_core': [], 'process': 0}, 'ram': {'total': 0, 'used_gb': 0, 'available_gb': 0, 'process_mb': 0}, 'gpu': {'total': 0, 'process': 0}, 'network': {'sent_mb': 0, 'recv_mb': 0, 'sent_speed': 0, 'recv_speed': 0}}
    
    @pyqtSlot(result='QVariantList')
    def getPerformanceHistory(self):
        """Retourne l'historique CPU/RAM/GPU pour les graphiques"""
        return [
            {
                'cpu': self.cpu_history[-60:] if self.cpu_history else [],
                'ram': self.ram_history[-60:] if self.ram_history else [],
                'gpu': self.gpu_history[-60:] if self.gpu_history else []
            }
        ]
    
    @pyqtSlot(result='QVariantMap')
    def getAppStats(self):
        try:
            profiles = self._load_json("profiles")
            clients = self._load_json("clients")
            dossiers = self._load_json("dossiers")
            adversaires = self._load_json("adversaires")
            missions_std = self._load_json("missions_standard")
            missions_prm = self._load_json("missions_premium")
            pieces = self._load_json("pieces")
            livrables = self._load_json("livrables")
            logs = self._load_json("logs")
            dossiers_ouverts = sum(1 for d in dossiers.values() if d.get('statut') == 'Ouvert')
            dossiers_fermes = sum(1 for d in dossiers.values() if d.get('statut') == 'Fermé')
            missions_en_cours = sum(1 for m in list(missions_std.values()) + list(missions_prm.values()) if m.get('statut') == 'En cours')
            missions_terminees = sum(1 for m in list(missions_std.values()) + list(missions_prm.values()) if m.get('statut') == 'Terminée')
            recent_logs = sum(1 for e in logs.get("entries", []) if datetime.fromisoformat(e.get('timestamp', '')).timestamp() >= datetime.now().timestamp() - (30 * 24 * 3600)) if "entries" in logs else 0
            return {
                'profiles': len(profiles), 'clients': len(clients), 'dossiers': len(dossiers), 'adversaires': len(adversaires),
                'missions_std': len(missions_std), 'missions_prm': len(missions_prm), 'pieces': len(pieces), 'livrables': len(livrables),
                'dossiers_ouverts': dossiers_ouverts, 'dossiers_fermes': dossiers_fermes,
                'missions_en_cours': missions_en_cours, 'missions_terminees': missions_terminees, 'missions_total': len(missions_std) + len(missions_prm),
                'vault_size': self.getVaultSize(), 'vault_files': self.getVaultFilesCount(), 'last_backup': self.getLastBackupDate(),
                'recent_activity': recent_logs, 'total_logs': len(logs.get("entries", [])),
                'user': self.current_user or "Utilisateur"
            }
        except:
            return {'profiles': 0, 'clients': 0, 'dossiers': 0, 'adversaires': 0, 'missions_std': 0, 'missions_prm': 0, 'pieces': 0, 'livrables': 0, 'vault_size': '0 KB', 'user': 'Utilisateur'}
    
    @pyqtSlot(int, result='QVariantList')
    def getRecentActivity(self, limit: int = 10):
        try:
            return self._load_json("logs").get("entries", [])[:limit]
        except:
            return []
    
    @pyqtSlot(str, result=str)
    def askIA(self, question: str):
        responses = {"requête": "Pour rédiger une requête, structurez en 3 parties: 1) Faits, 2) Droit applicable, 3) Demandes.", "document": "L'analyse de document nécessite l'intégration d'une API IA.", "contrat": "Pour générer un contrat, précisez le type (vente, prestation, bail).", "conseils": "Pour des conseils juridiques personnalisés, consultez un avocat."}
        for key, response in responses.items():
            if key in question.lower():
                return response
        return f"Assistant IA en mode simulation. Question: '{question}'"

    @pyqtSlot(str, str)
    def saveProfileImage(self, username: str, imagePath: str):
        """Sauvegarde l'image de profil dans le vault"""
        try:
            if not self.current_user:
                return
            
            import base64
            
            # Nettoyer le chemin (supprimer file:///)
            clean_path = imagePath.replace("file:///", "").replace("file://", "")
            
            # Lire l'image et convertir en base64
            with open(clean_path, 'rb') as f:
                image_data = f.read()
                image_base64 = base64.b64encode(image_data).decode('utf-8')
                
                # Déterminer le type MIME
                ext = clean_path.lower().split('.')[-1]
                mime_types = {
                    'png': 'image/png',
                    'jpg': 'image/jpeg',
                    'jpeg': 'image/jpeg',
                    'gif': 'image/gif',
                    'bmp': 'image/bmp'
                }
                mime_type = mime_types.get(ext, 'image/png')
                
                # Format data URI
                data_uri = f"data:{mime_type};base64,{image_base64}"
            
            # Sauvegarder dans vault
            profile_images = self._load_json("profile_images")
            if not profile_images:
                profile_images = {}
            
            profile_images[username] = data_uri
            self._save_json("profile_images", profile_images)
            
            print(f"[INFO] Image de profil sauvegardée pour {username}")
            
        except Exception as e:
            print(f"[ERROR] Erreur sauvegarde image profil: {e}")
            import traceback
            traceback.print_exc()
    
    @pyqtSlot(str, result=str)
    def loadProfileImage(self, username: str):
        """Charge l'image de profil depuis le vault"""
        try:
            profile_images = self._load_json("profile_images")
            if profile_images and username in profile_images:
                return profile_images[username]
            return ""
        except Exception as e:
            print(f"[ERROR] Erreur chargement image profil: {e}")
            return ""
    
    @pyqtSlot(result=str)
    def loadCloudAccounts(self):
        """Charge les comptes cloud depuis le vault"""
        try:
            if not self.current_user:
                return "[]"
            
            cloud_data = self._load_json("cloud_accounts")
            if cloud_data and "accounts" in cloud_data:
                return json.dumps(cloud_data["accounts"])
            return "[]"
        except Exception as e:
            print(f"[ERROR] Erreur chargement comptes cloud: {e}")
            return "[]"
    
    @pyqtSlot(str)
    def saveCloudAccounts(self, accountsJson: str):
        """Sauvegarde les comptes cloud dans le vault"""
        try:
            if not self.current_user:
                return
            
            accounts = json.loads(accountsJson)
            cloud_data = {"accounts": accounts, "last_sync": datetime.now().isoformat()}
            self._save_json("cloud_accounts", cloud_data)
            
            self.logActivity("☁️", "Comptes cloud mis à jour", f"{len(accounts)} compte(s)")
        except Exception as e:
            print(f"[ERROR] Erreur sauvegarde comptes cloud: {e}")
    
    @pyqtSlot(str, str, result=str)
    def connectCloudProvider(self, provider: str, credentials: str):
        """Connecte un provider cloud"""
        try:
            creds = json.loads(credentials)
            
            account_info = {
                "id": f"acc_{provider}_{int(time.time())}",
                "provider": provider,
                "name": provider.capitalize(),
                "email": creds.get("email", "user@example.com"),
                "connected": True,
                "usedSpace": 5368709120,
                "totalSpace": 16106127360,
                "credentials": credentials
            }
            
            self.logActivity("☁️", f"Compte {provider} connecté", account_info["email"])
            return json.dumps(account_info)
            
        except Exception as e:
            print(f"[ERROR] Erreur connexion cloud: {e}")
            return json.dumps({"error": str(e)})
    
    @pyqtSlot(str, str, result=str)
    def listCloudFiles(self, accountId: str, path: str):
        """Liste les fichiers d'un compte cloud"""
        try:
            files = [
                {"name": "Documents", "isFolder": True, "size": 0, "modified": datetime.now().strftime("%d/%m/%Y"), "localCopy": False, "path": path + "Documents/"},
                {"name": "Photos", "isFolder": True, "size": 0, "modified": "10/12/2025", "localCopy": True, "path": path + "Photos/"},
                {"name": "Contrat_2025.pdf", "isFolder": False, "size": 2048576, "modified": "08/12/2025", "localCopy": False, "path": path + "Contrat_2025.pdf"}
            ]
            return json.dumps(files)
        except Exception as e:
            print(f"[ERROR] Erreur liste fichiers cloud: {e}")
            return "[]"
    
    @pyqtSlot(str, str, str)
    def downloadFileToVault(self, accountId: str, filepath: str, filename: str):
        """Télécharge un fichier cloud vers le vault"""
        try:
            if not self.current_user:
                print("[ERROR] Pas d'utilisateur connecté")
                return
            
            print(f"[INFO] Téléchargement: {filename} depuis {accountId}")
            
            cloud_local_dir = self.vault_dir / "vault" / self.current_user / "cloud_files"
            cloud_local_dir.mkdir(parents=True, exist_ok=True)
            
            cloud_files = self._load_json("cloud_files_local")
            if not cloud_files:
                cloud_files = {"files": {}}
            
            file_key = f"{accountId}:{filepath}"
            cloud_files["files"][file_key] = {
                "filename": filename,
                "accountId": accountId,
                "filepath": filepath,
                "downloaded": datetime.now().isoformat(),
                "size": 0
            }
            
            self._save_json("cloud_files_local", cloud_files)
            self.logActivity("⬇️", "Fichier téléchargé", f"{filename}")
            self.dataChanged.emit()
            
        except Exception as e:
            print(f"[ERROR] Erreur téléchargement: {e}")
    
    @pyqtSlot(str, str)
    def deleteLocalCopy(self, accountId: str, filepath: str):
        """Supprime la copie locale d'un fichier cloud"""
        try:
            cloud_files = self._load_json("cloud_files_local")
            if not cloud_files:
                return
            
            file_key = f"{accountId}:{filepath}"
            if file_key in cloud_files.get("files", {}):
                filename = cloud_files["files"][file_key]["filename"]
                del cloud_files["files"][file_key]
                self._save_json("cloud_files_local", cloud_files)
                self.logActivity("🗑️", "Copie locale supprimée", filename)
                self.dataChanged.emit()
                
        except Exception as e:
            print(f"[ERROR] Erreur suppression locale: {e}")
    
    @pyqtSlot(str)
    def syncAccount(self, accountId: str):
        """Synchronise un compte cloud"""
        try:
            print(f"[INFO] Synchronisation compte: {accountId}")
            self.logActivity("🔄", "Synchronisation", f"Compte {accountId}")
            self.dataChanged.emit()
        except Exception as e:
            print(f"[ERROR] Erreur sync: {e}")
    
    @pyqtSlot(str)
    def disconnectCloudAccount(self, accountId: str):
        """Déconnecte un compte cloud"""
        try:
            accounts_json = self.loadCloudAccounts()
            accounts = json.loads(accounts_json)
            accounts = [acc for acc in accounts if acc.get("id") != accountId]
            self.saveCloudAccounts(json.dumps(accounts))
            self.logActivity("🔌", "Compte déconnecté", accountId)
            self.dataChanged.emit()
        except Exception as e:
            print(f"[ERROR] Erreur déconnexion: {e}")


    @pyqtSlot(str)
    def saveFavorites(self, favoritesJson: str):
        """Sauvegarde les favoris dans le vault"""
        try:
            if not self.current_user:
                return
            
            favorites = json.loads(favoritesJson)
            favorites_data = {
                "favorites": favorites,
                "last_updated": datetime.now().isoformat()
            }
            self._save_json("user_favorites", favorites_data)
            print(f"[INFO] Favoris sauvegardés: {len(favorites)} élément(s)")
            
        except Exception as e:
            print(f"[ERROR] Erreur sauvegarde favoris: {e}")
    
    @pyqtSlot(result=str)
    def loadFavorites(self):
        """Charge les favoris depuis le vault"""
        try:
            if not self.current_user:
                return "[]"
            
            favorites_data = self._load_json("user_favorites")
            if favorites_data and "favorites" in favorites_data:
                return json.dumps(favorites_data["favorites"])
            return "[]"
            
        except Exception as e:
            print(f"[ERROR] Erreur chargement favoris: {e}")
            return "[]"

    @pyqtSlot(result=str)
    def selectImageFile(self):
        """Ouvre un dialog pour sélectionner une image"""
        try:
            from PyQt6.QtWidgets import QFileDialog
            
            file_path, _ = QFileDialog.getOpenFileName(
                None,
                "Sélectionner une image",
                "",
                "Images (*.png *.jpg *.jpeg *.bmp *.gif)"
            )
            
            if file_path:
                print(f"[INFO] Image sélectionnée: {file_path}")
                return file_path
            return ""
            
        except Exception as e:
            print(f"[ERROR] Erreur sélection image: {e}")
            return ""

    @pyqtSlot(str)
    def saveNavigationHistory(self, historyJson: str):
        """Sauvegarde l'historique de navigation dans le vault"""
        try:
            if not self.current_user:
                return
            
            history = json.loads(historyJson)
            history_data = {
                "history": history[-100:],  # Garder les 100 derniers
                "last_updated": datetime.now().isoformat()
            }
            self._save_json("navigation_history", history_data)
            
        except Exception as e:
            print(f"[ERROR] Erreur sauvegarde historique: {e}")
    
    @pyqtSlot(result=str)
    def loadNavigationHistory(self):
        """Charge l'historique de navigation depuis le vault"""
        try:
            if not self.current_user:
                return "[]"
            
            history_data = self._load_json("navigation_history")
            if history_data and "history" in history_data:
                return json.dumps(history_data["history"])
            return "[]"
            
        except Exception as e:
            print(f"[ERROR] Erreur chargement historique: {e}")
            return "[]"
    
    @pyqtSlot()
    def clearNavigationHistory(self):
        """Efface l'historique de navigation"""
        try:
            if not self.current_user:
                return
            
            self._save_json("navigation_history", {"history": [], "last_updated": datetime.now().isoformat()})
            print("[INFO] Historique de navigation effacé")
            
        except Exception as e:
            print(f"[ERROR] Erreur effacement historique: {e}")

def main():
    print("[INFO] Démarrage NEOSIRIS...")
    app = QApplication(sys.argv)
    app.setApplicationName("NEOSIRIS")
    app.setWindowIcon(QIcon(str(Path(__file__).parent.parent.parent / "assets" / "Neosiris.ico")))
    engine = QQmlApplicationEngine()
    neosiris = NeosirisApp()
    engine.rootContext().setContextProperty("app", neosiris)
    engine.rootContext().setContextProperty("profilesModule", neosiris.profiles_module)
    engine.rootContext().setContextProperty("clientsModule", neosiris.clients_module)
    engine.rootContext().setContextProperty("adversairesModule", neosiris.adversaires_module)
    qml_file = Path(__file__).parent / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    if not engine.rootObjects():
        print("[ERROR] Échec chargement UI")
        return -1
    print("[INFO] ✅ NEOSIRIS démarré")
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
