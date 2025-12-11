"""
Module de gestion des adversaires et représentants
"""
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
from datetime import datetime


class AdversairesModule(QObject):
    dataChanged = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        self._load_json = None
        self._save_json = None
    
    @pyqtSlot(result=list)
    def getAdversaires(self):
        """Récupère la liste des adversaires"""
        if not self._load_json:
            return []
        
        data = self._load_json("adversaires")
        adversaires = list(data.values()) if data else []
        print(f"[DEBUG] Adversaires chargés: {len(adversaires)}")
        return adversaires
    
    @pyqtSlot('QVariantMap', result=str)
    def addAdversaire(self, adversaire_data: dict) -> str:
        """Ajoute un nouvel adversaire"""
        if not self._save_json or not self._load_json:
            return ""
        
        adversaire_id = f"ADV_{datetime.now().strftime('%Y%m%d%H%M%S%f')}"
        
        adversaire = {
            "id": adversaire_id,
            "name": adversaire_data.get("name", ""),
            "email": adversaire_data.get("email", ""),
            "phone": adversaire_data.get("phone", ""),
            "address": adversaire_data.get("address", ""),
            "notes": adversaire_data.get("notes", ""),
            "image": adversaire_data.get("image", ""),
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat()
        }
        
        data = self._load_json("adversaires")
        data[adversaire_id] = adversaire
        self._save_json("adversaires", data)
        
        print(f"[LOG] ⚔️ Adversaire créé: {adversaire['name']}")
        self.dataChanged.emit()
        return adversaire_id
    
    @pyqtSlot('QVariantMap')
    def updateAdversaire(self, adversaire_data: dict):
        """Met à jour un adversaire existant"""
        if not self._save_json or not self._load_json:
            return
        
        adversaire_id = adversaire_data.get("id")
        if not adversaire_id:
            return
        
        data = self._load_json("adversaires")
        if adversaire_id not in data:
            return
        
        data[adversaire_id].update({
            "name": adversaire_data.get("name", ""),
            "email": adversaire_data.get("email", ""),
            "phone": adversaire_data.get("phone", ""),
            "address": adversaire_data.get("address", ""),
            "notes": adversaire_data.get("notes", ""),
            "image": adversaire_data.get("image", ""),
            "updated": datetime.now().isoformat()
        })
        
        self._save_json("adversaires", data)
        print(f"[LOG] ⚔️ Adversaire modifié: {data[adversaire_id]['name']}")
        self.dataChanged.emit()
    
    @pyqtSlot(str)
    def deleteAdversaire(self, adversaire_id: str):
        """Supprime un adversaire"""
        if not self._save_json or not self._load_json:
            return
        
        data = self._load_json("adversaires")
        if adversaire_id in data:
            name = data[adversaire_id].get("name", "")
            del data[adversaire_id]
            self._save_json("adversaires", data)
            print(f"[LOG] ⚔️ Adversaire supprimé: {name}")
            self.dataChanged.emit()
    
    @pyqtSlot(result=list)
    def getRepresentants(self):
        """Récupère la liste des représentants"""
        if not self._load_json:
            return []
        
        data = self._load_json("representants")
        representants = list(data.values()) if data else []
        print(f"[DEBUG] Représentants chargés: {len(representants)}")
        return representants
    
    @pyqtSlot('QVariantMap', result=str)
    def addRepresentant(self, representant_data: dict) -> str:
        """Ajoute un nouveau représentant"""
        if not self._save_json or not self._load_json:
            return ""
        
        representant_id = f"REP_{datetime.now().strftime('%Y%m%d%H%M%S%f')}"
        
        representant = {
            "id": representant_id,
            "name": representant_data.get("name", ""),
            "email": representant_data.get("email", ""),
            "phone": representant_data.get("phone", ""),
            "address": representant_data.get("address", ""),
            "notes": representant_data.get("notes", ""),
            "image": representant_data.get("image", ""),
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat()
        }
        
        data = self._load_json("representants")
        data[representant_id] = representant
        self._save_json("representants", data)
        
        print(f"[LOG] 👔 Représentant créé: {representant['name']}")
        self.dataChanged.emit()
        return representant_id
    
    @pyqtSlot('QVariantMap')
    def updateRepresentant(self, representant_data: dict):
        """Met à jour un représentant existant"""
        if not self._save_json or not self._load_json:
            return
        
        representant_id = representant_data.get("id")
        if not representant_id:
            return
        
        data = self._load_json("representants")
        if representant_id not in data:
            return
        
        data[representant_id].update({
            "name": representant_data.get("name", ""),
            "email": representant_data.get("email", ""),
            "phone": representant_data.get("phone", ""),
            "address": representant_data.get("address", ""),
            "notes": representant_data.get("notes", ""),
            "image": representant_data.get("image", ""),
            "updated": datetime.now().isoformat()
        })
        
        self._save_json("representants", data)
        print(f"[LOG] 👔 Représentant modifié: {data[representant_id]['name']}")
        self.dataChanged.emit()
    
    @pyqtSlot(str)
    def deleteRepresentant(self, representant_id: str):
        """Supprime un représentant"""
        if not self._save_json or not self._load_json:
            return
        
        data = self._load_json("representants")
        if representant_id in data:
            name = data[representant_id].get("name", "")
            del data[representant_id]
            self._save_json("representants", data)
            print(f"[LOG] 👔 Représentant supprimé: {name}")
            self.dataChanged.emit()
