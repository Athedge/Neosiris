"""
NEOSIRIS - License Manager
Gestion des licences compatible avec Activateur externe
HKDF + AES-256-GCM encryption
"""

import os
import json
from pathlib import Path
from datetime import datetime, timedelta

from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal

from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM


class LicenseManager(QObject):
    """Gestionnaire de licences compatible Activateur"""
    
    licenseStatusChanged = pyqtSignal(bool)  # True=valide, False=invalide
    
    def __init__(self):
        super().__init__()
        self.license_file = Path.home() / "neosiris_vault" / "license.enc"
        self.license_data = None
        self.is_licensed = False
        
        # Clé de dérivation pour licence (partagée avec Activateur)
        self.LICENSE_INFO = b'neosiris-license-v1'
        
        # Pas besoin de signaux ici
    
    def _derive_license_key(self, machine_id: str, salt: bytes) -> bytes:
        """Dérive la clé de licence depuis machine_id"""
        kdf = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            info=self.LICENSE_INFO
        )
        return kdf.derive(machine_id.encode('utf-8'))
    
    def _get_machine_id(self) -> str:
        """Récupère l'identifiant unique de la machine"""
        import platform
        import uuid
        
        # Combinaison de plusieurs identifiants
        machine_uuid = str(uuid.getnode())
        hostname = platform.node()
        system = platform.system()
        
        return f"{machine_uuid}-{hostname}-{system}"
    
    def _decrypt_license(self, encrypted_data: bytes, machine_id: str) -> dict:
        """Déchiffre la licence"""
        try:
            salt = encrypted_data[:16]
            nonce = encrypted_data[16:28]
            ciphertext = encrypted_data[28:]
            
            key = self._derive_license_key(machine_id, salt)
            aesgcm = AESGCM(key)
            decrypted = aesgcm.decrypt(nonce, ciphertext, None)
            
            return json.loads(decrypted.decode('utf-8'))
        except Exception as e:
            print(f"[ERROR] Decrypt license: {e}")
            return None
    
    def _encrypt_license(self, data: dict, machine_id: str) -> bytes:
        """Chiffre la licence"""
        try:
            salt = os.urandom(16)
            nonce = os.urandom(12)
            
            key = self._derive_license_key(machine_id, salt)
            aesgcm = AESGCM(key)
            
            json_data = json.dumps(data, ensure_ascii=False)
            ciphertext = aesgcm.encrypt(nonce, json_data.encode('utf-8'), None)
            
            return salt + nonce + ciphertext
        except Exception as e:
            print(f"[ERROR] Encrypt license: {e}")
            return None
    
    @pyqtSlot(result=bool)
    def checkLicense(self):
        """Vérifie la validité de la licence"""
        if not self.license_file.exists():
            self.is_licensed = False
            return False
        
        try:
            machine_id = self._get_machine_id()
            encrypted = self.license_file.read_bytes()
            self.license_data = self._decrypt_license(encrypted, machine_id)
            
            if not self.license_data:
                self.is_licensed = False
                return False
            
            # Vérifier machine_id
            if self.license_data.get('machine_id') != machine_id:
                print("[ERROR] License: Machine ID mismatch")
                self.is_licensed = False
                return False
            
            # Vérifier expiration
            expiry = datetime.fromisoformat(self.license_data.get('expiry_date', '2000-01-01'))
            if datetime.now() > expiry:
                print("[ERROR] License: Expired")
                self.is_licensed = False
                return False
            
            # Vérifier type
            license_type = self.license_data.get('type', 'trial')
            if license_type not in ['trial', 'standard', 'premium', 'enterprise']:
                print("[ERROR] License: Invalid type")
                self.is_licensed = False
                return False
            
            self.is_licensed = True
            print(f"[INFO] License OK: {license_type} until {expiry.strftime('%d/%m/%Y')}")
            return True
            
        except Exception as e:
            print(f"[ERROR] Check license: {e}")
            self.is_licensed = False
            return False
    
    @pyqtSlot(str, result=bool)
    def activateLicense(self, license_key: str):
        """Active une licence (simulation - vraie activation via Activateur externe)"""
        try:
            # Parse license key (format: TYPE-DURATION-CHECKSUM)
            parts = license_key.split('-')
            if len(parts) != 3:
                return False
            
            license_type = parts[0].lower()
            duration_days = int(parts[1])
            
            if license_type not in ['trial', 'standard', 'premium', 'enterprise']:
                return False
            
            # Créer licence
            machine_id = self._get_machine_id()
            license_data = {
                'machine_id': machine_id,
                'type': license_type,
                'activation_date': datetime.now().isoformat(),
                'expiry_date': (datetime.now() + timedelta(days=duration_days)).isoformat(),
                'license_key': license_key
            }
            
            # Chiffrer et sauvegarder
            encrypted = self._encrypt_license(license_data, machine_id)
            if encrypted:
                self.license_file.write_bytes(encrypted)
                self.license_data = license_data
                self.is_licensed = True
                return True
            
            return False
        except Exception as e:
            print(f"[ERROR] Activate license: {e}")
            return False
    
    @pyqtSlot(result='QVariantMap')
    def getLicenseInfo(self):
        """Retourne les informations de licence"""
        if not self.checkLicense():
            return {
                'status': 'invalid',
                'type': 'none',
                'expiry_date': '',
                'days_remaining': 0
            }
        
        expiry = datetime.fromisoformat(self.license_data['expiry_date'])
        days_remaining = (expiry - datetime.now()).days
        
        return {
            'status': 'valid',
            'type': self.license_data.get('type', 'trial'),
            'expiry_date': expiry.strftime('%d/%m/%Y'),
            'days_remaining': max(0, days_remaining),
            'machine_id': self._get_machine_id()[:16] + "..."  # Tronqué pour affichage
        }
    
    @pyqtSlot(result=str)
    def getMachineId(self):
        """Retourne le machine ID (pour activation externe)"""
        return self._get_machine_id()
    
    @pyqtSlot(result=bool)
    def isFeatureEnabled(self, feature: str):
        """Vérifie si une fonctionnalité est activée selon la licence"""
        if not self.is_licensed:
            return False
        
        license_type = self.license_data.get('type', 'trial')
        
        # Mapping features par type de licence
        features_map = {
            'trial': ['basic_vault', 'profiles', 'clients', 'dossiers'],
            'standard': ['basic_vault', 'profiles', 'clients', 'dossiers', 'ia_assistant', 'base_juridique'],
            'premium': ['basic_vault', 'profiles', 'clients', 'dossiers', 'ia_assistant', 'base_juridique', 'ocr', 'advanced_search'],
            'enterprise': ['all']  # Toutes fonctionnalités
        }
        
        if license_type == 'enterprise':
            return True
        
        return feature in features_map.get(license_type, [])
