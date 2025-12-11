"""
NEOSIRIS - Module Dashboard
Tableau de bord avec statistiques et monitoring
"""

from PyQt6.QtCore import QObject, pyqtSlot, QTimer
from datetime import datetime
import psutil
import platform


class DashboardModule(QObject):
    """Module Dashboard - Statistiques et vue d'ensemble"""
    
    def __init__(self):
        super().__init__()
        
        # Timer pour mise à jour performances en temps réel
        self.perf_timer = QTimer()
        self.perf_timer.timeout.connect(self._update_performance_data)
        self.perf_timer.start(1000)  # Actualisation chaque seconde
        
        # Historique performances (60 dernières secondes)
        self.cpu_history = []
        self.ram_history = []
        self.network_history = []
    
    def _update_performance_data(self):
        """Met à jour l'historique des performances"""
        try:
            # CPU
            cpu_percent = psutil.cpu_percent(interval=0.1)
            self.cpu_history.append(cpu_percent)
            if len(self.cpu_history) > 60:
                self.cpu_history.pop(0)
            
            # RAM
            ram = psutil.virtual_memory()
            self.ram_history.append(ram.percent)
            if len(self.ram_history) > 60:
                self.ram_history.pop(0)
            
            # Network
            net = psutil.net_io_counters()
            network_usage = (net.bytes_sent + net.bytes_recv) / (1024 * 1024)  # MB
            self.network_history.append(network_usage)
            if len(self.network_history) > 60:
                self.network_history.pop(0)
        except:
            pass
    
    @pyqtSlot(result='QVariantMap')
    def getSystemInfo(self):
        """Retourne informations système complètes"""
        try:
            # OS
            os_info = {
                'system': platform.system(),
                'release': platform.release(),
                'version': platform.version(),
                'machine': platform.machine(),
                'processor': platform.processor()
            }
            
            # CPU
            cpu_info = {
                'physical_cores': psutil.cpu_count(logical=False),
                'logical_cores': psutil.cpu_count(logical=True),
                'max_frequency': f"{psutil.cpu_freq().max:.0f} MHz" if psutil.cpu_freq() else "N/A",
                'current_frequency': f"{psutil.cpu_freq().current:.0f} MHz" if psutil.cpu_freq() else "N/A"
            }
            
            # RAM
            ram = psutil.virtual_memory()
            ram_info = {
                'total': f"{ram.total / (1024**3):.1f} GB",
                'available': f"{ram.available / (1024**3):.1f} GB",
                'used': f"{ram.used / (1024**3):.1f} GB",
                'percent': ram.percent
            }
            
            # Disque
            disk = psutil.disk_usage('/')
            disk_info = {
                'total': f"{disk.total / (1024**3):.1f} GB",
                'used': f"{disk.used / (1024**3):.1f} GB",
                'free': f"{disk.free / (1024**3):.1f} GB",
                'percent': disk.percent
            }
            
            # GPU (basique, pas de pilotes détaillés sans bibliothèque spécifique)
            gpu_info = {
                'available': 'Détection GPU nécessite module GPU-specific',
                'driver': 'N/A'
            }
            
            return {
                'os': os_info,
                'cpu': cpu_info,
                'ram': ram_info,
                'disk': disk_info,
                'gpu': gpu_info
            }
        except Exception as e:
            print(f"[ERROR] Get system info: {e}")
            return {}
    
    @pyqtSlot(result='QVariantMap')
    def getCurrentPerformance(self):
        """Retourne performances actuelles en temps réel"""
        try:
            # CPU
            cpu_percent = psutil.cpu_percent(interval=0.1)
            cpu_per_core = psutil.cpu_percent(interval=0.1, percpu=True)
            
            # RAM
            ram = psutil.virtual_memory()
            
            # GPU - placeholder (nécessite pynvml pour NVIDIA ou équivalent)
            gpu_percent = 0
            
            # Réseau
            net = psutil.net_io_counters()
            
            # Process courant
            import os as os_module
            process = psutil.Process(os_module.getpid())
            process_cpu = process.cpu_percent(interval=0.1)
            process_ram = process.memory_info().rss / (1024**2)  # MB
            
            return {
                'cpu': {
                    'total': cpu_percent,
                    'per_core': cpu_per_core,
                    'process': process_cpu
                },
                'ram': {
                    'total': ram.percent,
                    'used_gb': ram.used / (1024**3),
                    'available_gb': ram.available / (1024**3),
                    'process_mb': process_ram
                },
                'gpu': {
                    'total': gpu_percent,
                    'process': 0
                },
                'network': {
                    'sent_mb': net.bytes_sent / (1024**2),
                    'recv_mb': net.bytes_recv / (1024**2),
                    'sent_speed': net.bytes_sent / (1024**2),
                    'recv_speed': net.bytes_recv / (1024**2)
                }
            }
        except Exception as e:
            print(f"[ERROR] Get performance: {e}")
            return {
                'cpu': {'total': 0, 'per_core': [], 'process': 0},
                'ram': {'total': 0, 'used_gb': 0, 'available_gb': 0, 'process_mb': 0},
                'gpu': {'total': 0, 'process': 0},
                'network': {'sent_mb': 0, 'recv_mb': 0, 'sent_speed': 0, 'recv_speed': 0}
            }
    
    @pyqtSlot(result='QVariantList')
    def getPerformanceHistory(self):
        """Retourne l'historique des performances"""
        history = []
        for i in range(min(len(self.cpu_history), len(self.ram_history))):
            history.append({
                'cpu': self.cpu_history[i],
                'ram': self.ram_history[i],
                'network': self.network_history[i] if i < len(self.network_history) else 0
            })
        return history
    
    @pyqtSlot(result='QVariantMap')
    def getAppStats(self):
        """Retourne statistiques complètes de l'application"""
        try:
            # Charger toutes les données
            profiles = self._load_json("profiles")
            clients = self._load_json("clients")
            dossiers = self._load_json("dossiers")
            adversaires = self._load_json("adversaires")
            missions_std = self._load_json("missions_standard")
            missions_prm = self._load_json("missions_premium")
            pieces = self._load_json("pieces")
            livrables = self._load_json("livrables")
            logs = self._load_json("logs")
            
            # Dossiers par statut
            dossiers_ouverts = sum(1 for d in dossiers.values() if d.get('statut') == 'Ouvert')
            dossiers_fermes = sum(1 for d in dossiers.values() if d.get('statut') == 'Fermé')
            
            # Missions par statut
            missions_en_cours = sum(1 for m in missions_std.values() if m.get('statut') == 'En cours')
            missions_en_cours += sum(1 for m in missions_prm.values() if m.get('statut') == 'En cours')
            missions_terminees = sum(1 for m in missions_std.values() if m.get('statut') == 'Terminée')
            missions_terminees += sum(1 for m in missions_prm.values() if m.get('statut') == 'Terminée')
            
            # Activité récente (30 derniers jours)
            recent_logs = 0
            if "entries" in logs:
                thirty_days_ago = datetime.now().timestamp() - (30 * 24 * 3600)
                for entry in logs["entries"]:
                    try:
                        log_time = datetime.fromisoformat(entry.get('timestamp', '')).timestamp()
                        if log_time >= thirty_days_ago:
                            recent_logs += 1
                    except:
                        pass
            
            return {
                # Compteurs principaux
                'profiles': len(profiles),
                'clients': len(clients),
                'dossiers': len(dossiers),
                'adversaires': len(adversaires),
                'missions_std': len(missions_std),
                'missions_prm': len(missions_prm),
                'pieces': len(pieces),
                'livrables': len(livrables),
                
                # Détails dossiers
                'dossiers_ouverts': dossiers_ouverts,
                'dossiers_fermes': dossiers_fermes,
                
                # Détails missions
                'missions_en_cours': missions_en_cours,
                'missions_terminees': missions_terminees,
                'missions_total': len(missions_std) + len(missions_prm),
                
                # Vault info
                'vault_size': self.getVaultSize(),
                'vault_files': self.getVaultFilesCount(),
                'last_backup': self.getLastBackupDate(),
                
                # Activité
                'recent_activity': recent_logs,
                'total_logs': len(logs.get("entries", [])),
                
                # User
                'user': self.current_user or "Utilisateur"
            }
        except Exception as e:
            print(f"[ERROR] Get stats: {e}")
            return {
                'profiles': 0,
                'clients': 0,
                'dossiers': 0,
                'adversaires': 0,
                'missions_std': 0,
                'missions_prm': 0,
                'pieces': 0,
                'livrables': 0,
                'vault_size': '0 KB',
                'user': 'Utilisateur'
            }
    
    @pyqtSlot(int, result='QVariantList')
    def getRecentActivity(self, limit: int = 10):
        """Retourne les activités récentes"""
        try:
            logs = self._load_json("logs")
            entries = logs.get("entries", [])
            return entries[:limit]
        except:
            return []
    
    @pyqtSlot(result='QVariantMap')
    def getDashboardCharts(self):
        """Retourne les données pour les graphiques du dashboard"""
        try:
            dossiers = self._load_json("dossiers")
            clients = self._load_json("clients")
            
            # Dossiers par type d'affaire
            types_affaires = {}
            for d in dossiers.values():
                type_affaire = d.get('type_affaire', 'Autre')
                types_affaires[type_affaire] = types_affaires.get(type_affaire, 0) + 1
            
            # Clients par type
            types_clients = {}
            for c in clients.values():
                type_client = c.get('type', 'Particulier')
                types_clients[type_client] = types_clients.get(type_client, 0) + 1
            
            return {
                'dossiers_par_type': types_affaires,
                'clients_par_type': types_clients
            }
        except Exception as e:
            print(f"[ERROR] Get charts: {e}")
            return {
                'dossiers_par_type': {},
                'clients_par_type': {}
            }
    
    @pyqtSlot(result='QVariantList')
    def getDossiersUrgents(self):
        """Retourne les dossiers urgents/prioritaires"""
        try:
            dossiers = self._load_json("dossiers")
            missions_std = self._load_json("missions_standard")
            missions_prm = self._load_json("missions_premium")
            
            urgents = []
            
            # Dossiers avec missions haute priorité
            for dossier_id, dossier in dossiers.items():
                if dossier.get('statut') == 'Ouvert':
                    has_urgent = False
                    
                    # Vérifier missions std
                    for mission in missions_std.values():
                        if mission.get('dossier_id') == dossier_id and mission.get('priority') == 'Haute':
                            has_urgent = True
                            break
                    
                    # Vérifier missions premium
                    if not has_urgent:
                        for mission in missions_prm.values():
                            if mission.get('dossier_id') == dossier_id and mission.get('priority') == 'Haute':
                                has_urgent = True
                                break
                    
                    if has_urgent:
                        urgents.append({
                            'id': dossier_id,
                            **dossier
                        })
            
            return urgents[:5]  # Top 5
        except:
            return []
