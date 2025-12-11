"""
NEOSIRIS - Module Profiles
Gestion des profils et avocats
"""

from PyQt6.QtCore import QObject, pyqtSlot, pyqtSignal
from PyQt6.QtWidgets import QFileDialog
from datetime import datetime
import json


class ProfilesModule(QObject):
    """Module de gestion des profils et avocats"""
    
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
    
    # ===== PROFILS =====
    
    @pyqtSlot(result='QVariantList')
    def getProfiles(self):
        """Retourne tous les profils"""
        data = self._load_json("profiles")
        return list(data.values()) if data else []
        print(f"[DEBUG] getProfiles retourne {len(result)} profils")
        return result
    
    @pyqtSlot(str, result='QVariantMap')
    def getProfile(self, profile_id: str):
        """Retourne un profil spécifique"""
        data = self._load_json("profiles")
        return data.get(profile_id, {})
    
    @pyqtSlot('QVariantMap')
    def addProfile(self, profile_data: dict):
        """Ajoute un nouveau profil"""
        data = self._load_json("profiles")
        
        profile_id = self._generate_id("PRF")
        profile = {
            "id": profile_id,
            "name": profile_data.get("name", ""),
            "firstName": profile_data.get("firstName", ""),
            "email": profile_data.get("email", ""),
            "phone": profile_data.get("phone", ""),
            "address": profile_data.get("address", ""),
            "notes": profile_data.get("notes", ""),
            "image": profile_data.get("image", ""),
            "active": profile_data.get("active", True),
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat()
        }
        
        data[profile_id] = profile
        self._save_json("profiles", data)

        print(f"[DEBUG] Profil ajouté: {profile}")
        print(f"[DEBUG] Nombre total profils: {len(data)}") 
        
        if self.logActivity:
            self.logActivity("👤", "Profil créé", profile["name"])
        
        self.dataChanged.emit()
    
    @pyqtSlot('QVariantMap')
    def updateProfile(self, profile_data: dict):
        """Met à jour un profil existant"""
        data = self._load_json("profiles")
        profile_id = profile_data.get("id")
        
        if profile_id and profile_id in data:
            data[profile_id].update({
                "name": profile_data.get("name", ""),
                "firstName": profile_data.get("firstName", ""),
                "email": profile_data.get("email", ""),
                "phone": profile_data.get("phone", ""),
                "address": profile_data.get("address", ""),
                "notes": profile_data.get("notes", ""),
                "image": profile_data.get("image", ""),
                "active": profile_data.get("active", True),
                "updated": datetime.now().isoformat()
            })
            
            self._save_json("profiles", data)
            
            if self.logActivity:
                self.logActivity("✏️", "Profil modifié", data[profile_id]["name"])
            
            self.dataChanged.emit()
    
    @pyqtSlot(str)
    def deleteProfile(self, profile_id: str):
        """Supprime un profil"""
        data = self._load_json("profiles")
        
        if profile_id in data:
            profile_name = data[profile_id].get("name", "")
            del data[profile_id]
            self._save_json("profiles", data)
            
            if self.logActivity:
                self.logActivity("🗑", "Profil supprimé", profile_name)
            
            self.dataChanged.emit()
    
    @pyqtSlot(str, bool)
    def toggleProfileActive(self, profile_id: str, active: bool):
        """Active/désactive un profil"""
        data = self._load_json("profiles")
        
        if profile_id in data:
            data[profile_id]["active"] = active
            data[profile_id]["updated"] = datetime.now().isoformat()
            self._save_json("profiles", data)
            
            if self.logActivity:
                status = "activé" if active else "désactivé"
                self.logActivity("🔄", f"Profil {status}", data[profile_id]["name"])
            
            self.dataChanged.emit()
    
    # ===== AVOCATS =====
    
    @pyqtSlot(result='QVariantList')
    def getLawyers(self):
        """Retourne tous les avocats"""
        data = self._load_json("lawyers")
        return list(data.values()) if data else []
    
    @pyqtSlot(str, result='QVariantMap')
    def getLawyer(self, lawyer_id: str):
        """Retourne un avocat spécifique"""
        data = self._load_json("lawyers")
        return data.get(lawyer_id, {})
    
    @pyqtSlot('QVariantMap')
    def addLawyer(self, lawyer_data: dict):
        """Ajoute un nouvel avocat (ton)"""
        data = self._load_json("lawyers")
        
        lawyer_id = self._generate_id("TON")
        lawyer = {
            "id": lawyer_id,
            "name": lawyer_data.get("name", ""),
            "title": lawyer_data.get("title", ""),
            "description": lawyer_data.get("description", ""),
            "image": lawyer_data.get("image", ""),
            "active": lawyer_data.get("active", True),
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat()
        }
        
        data[lawyer_id] = lawyer
        self._save_json("lawyers", data)
        
        if self.logActivity:
            self.logActivity("🎭", "Ton créé", lawyer["name"])
        
        self.dataChanged.emit()
    
    @pyqtSlot('QVariantMap')
    def updateLawyer(self, lawyer_data: dict):
        """Met à jour un avocat existant"""
        data = self._load_json("lawyers")
        lawyer_id = lawyer_data.get("id")
        
        if lawyer_id and lawyer_id in data:
            data[lawyer_id].update({
                "name": lawyer_data.get("name", ""),
                "title": lawyer_data.get("title", ""),
                "description": lawyer_data.get("description", ""),
                "image": lawyer_data.get("image", ""),
                "active": lawyer_data.get("active", True),
                "updated": datetime.now().isoformat()
            })
            
            self._save_json("lawyers", data)
            
            if self.logActivity:
                self.logActivity("✏️", "Ton modifié", data[lawyer_id]["name"])
            
            self.dataChanged.emit()
    
    @pyqtSlot(str)
    def deleteLawyer(self, lawyer_id: str):
        """Supprime un avocat"""
        data = self._load_json("lawyers")
        
        if lawyer_id in data:
            lawyer_name = data[lawyer_id].get("name", "")
            del data[lawyer_id]
            self._save_json("lawyers", data)
            
            if self.logActivity:
                self.logActivity("🗑", "Ton supprimé", lawyer_name)
            
            self.dataChanged.emit()
    
    @pyqtSlot(str, bool)
    def toggleLawyerActive(self, lawyer_id: str, active: bool):
        """Active/désactive un avocat"""
        data = self._load_json("lawyers")
        
        if lawyer_id in data:
            data[lawyer_id]["active"] = active
            data[lawyer_id]["updated"] = datetime.now().isoformat()
            self._save_json("lawyers", data)
            
            if self.logActivity:
                status = "activé" if active else "désactivé"
                self.logActivity("🔄", f"Ton {status}", data[lawyer_id]["name"])
            
            self.dataChanged.emit()
