"""
Module de gestion des clients, dossiers et conventions
"""
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
from datetime import datetime
import uuid


class ClientsModule(QObject):
    dataChanged = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        self._load_json = None
        self._save_json = None
    
    @pyqtSlot(result=list)
    def getClients(self):
        """Récupère la liste des clients"""
        if not self._load_json:
            return []
        
        data = self._load_json("clients")
        clients = list(data.values()) if data else []
        print(f"[DEBUG] Clients chargés: {len(clients)}")
        return clients
    
    @pyqtSlot(str, result='QVariantMap')
    def getClient(self, client_id: str):
        """Récupère un client par son ID"""
        if not self._load_json:
            return {}
        
        data = self._load_json("clients")
        return data.get(client_id, {})
    
    @pyqtSlot('QVariantMap', result=str)
    def addClient(self, client_data: dict) -> str:
        """Ajoute un nouveau client"""
        if not self._save_json or not self._load_json:
            return ""
        
        client_id = f"CLI_{datetime.now().strftime('%Y%m%d%H%M%S%f')}"
        
        client = {
            "id": client_id,
            "name": client_data.get("name", ""),
            "email": client_data.get("email", ""),
            "phone": client_data.get("phone", ""),
            "address": client_data.get("address", ""),
            "notes": client_data.get("notes", ""),
            "image": client_data.get("image", ""),
            "created": datetime.now().isoformat(),
            "updated": datetime.now().isoformat()
        }
        
        data = self._load_json("clients")
        data[client_id] = client
        self._save_json("clients", data)
        
        print(f"[LOG] 👥 Client créé: {client['name']}")
        self.dataChanged.emit()
        return client_id
    
    @pyqtSlot('QVariantMap')
    def updateClient(self, client_data: dict):
        """Met à jour un client existant"""
        if not self._save_json or not self._load_json:
            return
        
        client_id = client_data.get("id")
        if not client_id:
            return
        
        data = self._load_json("clients")
        if client_id not in data:
            return
        
        data[client_id].update({
            "name": client_data.get("name", ""),
            "email": client_data.get("email", ""),
            "phone": client_data.get("phone", ""),
            "address": client_data.get("address", ""),
            "notes": client_data.get("notes", ""),
            "image": client_data.get("image", ""),
            "updated": datetime.now().isoformat()
        })
        
        self._save_json("clients", data)
        print(f"[LOG] 👥 Client modifié: {data[client_id]['name']}")
        self.dataChanged.emit()
    
    @pyqtSlot(str)
    def deleteClient(self, client_id: str):
        """Supprime un client"""
        if not self._save_json or not self._load_json:
            return
        
        data = self._load_json("clients")
        if client_id in data:
            name = data[client_id].get("name", "")
            del data[client_id]
            self._save_json("clients", data)
            print(f"[LOG] 👥 Client supprimé: {name}")
            self.dataChanged.emit()
    
    @pyqtSlot(result=list)
    def getDossiers(self):
        """Récupère la liste des dossiers"""
        if not self._load_json:
            return []
        
        data = self._load_json("dossiers")
        return list(data.values()) if data else []
    
    @pyqtSlot(result=list)
    def getConventions(self):
        """Récupère la liste des conventions"""
        if not self._load_json:
            return []
        
        data = self._load_json("conventions")
        return list(data.values()) if data else []
