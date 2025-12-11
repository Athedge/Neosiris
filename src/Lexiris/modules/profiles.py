"""
NEOSIRIS - Module Profiles
Gestion des profils et tons pour l'IA
"""

from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal
from PyQt6.QtWidgets import QFileDialog
from datetime import datetime
import json


class ProfilesModule(QObject):
    """Module de gestion des profils et tons"""
    
    dataChanged = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        # Ces méthodes seront injectées depuis main.py
        self._load_json = None
        self._save_json = None
        self.logActivity = None
    
    def _generate_id(self, prefix: str) -> str:
        """Génère un ID unique"""
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S%f")
        return f"{prefix}_{timestamp}"
    
    @pyqtSlot(result=str)
    def selectImageFile(self):
        """Ouvre un sélecteur de fichier pour choisir une image"""
        file_path, _ = QFileDialog.getOpenFileName(
            None,
            "Sélectionner une image",
            "",
            "Images (*.png *.jpg *.jpeg *.bmp *.gif)"
        )
        if file_path:
            return f"file:///{file_path.replace(chr(92), '/')}"
        return ""
    
    # ===== PROFILS =====
    
    @pyqtSlot(result='QVariantList')
    def getProfiles(self):
        """Retourne tous les profils"""
        if not self._load_json:
            return []
        
        profiles = self._load_json("profiles")
        return [{"id": k, **v} for k, v in profiles.items()]
    
    @pyqtSlot(str, result='QVariantMap')
    def getProfile(self, profile_id: str):
        """Retourne un profil spécifique"""
        if not self._load_json:
            return {}
        
        profiles = self._load_json("profiles")
        profile = profiles.get(profile_id, {})
        if profile:
            profile["id"] = profile_id
        return profile
    
    @pyqtSlot('QVariantMap')
    def addProfile(self, data: dict):
        """Ajoute un nouveau profil"""
        if not self._save_json:
            return
        
        profiles = self._load_json("profiles")
        profile_id = self._generate_id("PRF")
        
        profiles[profile_id] = {
            "name": data.get("name", ""),
            "firstName": data.get("firstName", ""),
            "email": data.get("email", ""),
            "phone": data.get("phone", ""),
            "image": data.get("image", ""),
            "description": data.get("description", ""),
            "active": data.get("active", True),
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat()
        }
        
        self._save_json("profiles", profiles)
        self.logActivity("👤", "Profil créé", data.get("name", ""))
        self.dataChanged.emit()
    
    @pyqtSlot('QVariantMap')
    def updateProfile(self, data: dict):
        """Met à jour un profil existant"""
        if not self._save_json:
            return
        
        profile_id = data.get("id")
        if not profile_id:
            return
        
        profiles = self._load_json("profiles")
        if profile_id not in profiles:
            return
        
        profiles[profile_id].update({
            "name": data.get("name", ""),
            "firstName": data.get("firstName", ""),
            "email": data.get("email", ""),
            "phone": data.get("phone", ""),
            "image": data.get("image", ""),
            "description": data.get("description", ""),
            "active": data.get("active", True),
            "updated": datetime.now().isoformat()
        })
        
        self._save_json("profiles", profiles)
        self.logActivity("✏️", "Profil modifié", data.get("name", ""))
        self.dataChanged.emit()
    
    @pyqtSlot(str)
    def deleteProfile(self, profile_id: str):
        """Supprime un profil"""
        if not self._save_json:
            return
        
        profiles = self._load_json("profiles")
        if profile_id in profiles:
            name = profiles[profile_id].get("name", "")
            del profiles[profile_id]
            self._save_json("profiles", profiles)
            self.logActivity("🗑️", "Profil supprimé", name)
            self.dataChanged.emit()
    
    @pyqtSlot(str, bool)
    def toggleProfileActive(self, profile_id: str, active: bool):
        """Active/désactive un profil"""
        if not self._save_json:
            return
        
        profiles = self._load_json("profiles")
        if profile_id in profiles:
            profiles[profile_id]["active"] = active
            profiles[profile_id]["updated"] = datetime.now().isoformat()
            self._save_json("profiles", profiles)
            status = "activé" if active else "désactivé"
            self.logActivity("🔄", f"Profil {status}", profiles[profile_id].get("name", ""))
            self.dataChanged.emit()
    
    @pyqtSlot(str, result=str)
    def exportProfile(self, profile_id: str):
        """Exporte un profil en JSON"""
        if not self._load_json:
            return ""
        
        profiles = self._load_json("profiles")
        if profile_id not in profiles:
            return ""
        
        profile = profiles[profile_id].copy()
        profile["id"] = profile_id
        
        try:
            json_data = json.dumps(profile, ensure_ascii=False, indent=2)
            filename = f"profile_{profile.get('name', profile_id)}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            
            # Sauvegarder dans le dossier exports du vault
            from pathlib import Path
            export_path = Path.home() / "neosiris_vault" / "exports" / filename
            export_path.write_text(json_data, encoding='utf-8')
            
            self.logActivity("📤", "Profil exporté", profile.get("name", ""))
            return str(export_path)
        except Exception as e:
            print(f"[ERROR] Export profile: {e}")
            return ""
    
    # ===== TONS =====
    
    @pyqtSlot(result='QVariantList')
    def getTones(self):
        """Retourne tous les tons"""
        if not self._load_json:
            return []
        
        tones = self._load_json("tones")
        return [{"id": k, **v} for k, v in tones.items()]
    
    @pyqtSlot(str, result='QVariantMap')
    def getTone(self, tone_id: str):
        """Retourne un ton spécifique"""
        if not self._load_json:
            return {}
        
        tones = self._load_json("tones")
        tone = tones.get(tone_id, {})
        if tone:
            tone["id"] = tone_id
        return tone
    
    @pyqtSlot('QVariantMap')
    def addTone(self, data: dict):
        """Ajoute un nouveau ton"""
        if not self._save_json:
            return
        
        tones = self._load_json("tones")
        tone_id = self._generate_id("TON")
        
        tones[tone_id] = {
            "name": data.get("name", ""),
            "toneType": data.get("toneType", "Formel"),
            "image": data.get("image", ""),
            "description": data.get("description", ""),
            "active": data.get("active", True),
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat()
        }
        
        self._save_json("tones", tones)
        self.logActivity("✍️", "Ton créé", data.get("name", ""))
        self.dataChanged.emit()
    
    @pyqtSlot('QVariantMap')
    def updateTone(self, data: dict):
        """Met à jour un ton existant"""
        if not self._save_json:
            return
        
        tone_id = data.get("id")
        if not tone_id:
            return
        
        tones = self._load_json("tones")
        if tone_id not in tones:
            return
        
        tones[tone_id].update({
            "name": data.get("name", ""),
            "toneType": data.get("toneType", "Formel"),
            "image": data.get("image", ""),
            "description": data.get("description", ""),
            "active": data.get("active", True),
            "updated": datetime.now().isoformat()
        })
        
        self._save_json("tones", tones)
        self.logActivity("✏️", "Ton modifié", data.get("name", ""))
        self.dataChanged.emit()
    
    @pyqtSlot(str)
    def deleteTone(self, tone_id: str):
        """Supprime un ton"""
        if not self._save_json:
            return
        
        tones = self._load_json("tones")
        if tone_id in tones:
            name = tones[tone_id].get("name", "")
            del tones[tone_id]
            self._save_json("tones", tones)
            self.logActivity("🗑️", "Ton supprimé", name)
            self.dataChanged.emit()
    
    @pyqtSlot(str, bool)
    def toggleToneActive(self, tone_id: str, active: bool):
        """Active/désactive un ton"""
        if not self._save_json:
            return
        
        tones = self._load_json("tones")
        if tone_id in tones:
            tones[tone_id]["active"] = active
            tones[tone_id]["updated"] = datetime.now().isoformat()
            self._save_json("tones", tones)
            status = "activé" if active else "désactivé"
            self.logActivity("🔄", f"Ton {status}", tones[tone_id].get("name", ""))
            self.dataChanged.emit()
    
    @pyqtSlot(str, result=str)
    def exportTone(self, tone_id: str):
        """Exporte un ton en JSON"""
        if not self._load_json:
            return ""
        
        tones = self._load_json("tones")
        if tone_id not in tones:
            return ""
        
        tone = tones[tone_id].copy()
        tone["id"] = tone_id
        
        try:
            json_data = json.dumps(tone, ensure_ascii=False, indent=2)
            filename = f"tone_{tone.get('name', tone_id)}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
            
            # Sauvegarder dans le dossier exports du vault
            from pathlib import Path
            export_path = Path.home() / "neosiris_vault" / "exports" / filename
            export_path.write_text(json_data, encoding='utf-8')
            
            self.logActivity("📤", "Ton exporté", tone.get("name", ""))
            return str(export_path)
        except Exception as e:
            print(f"[ERROR] Export tone: {e}")
            return ""
