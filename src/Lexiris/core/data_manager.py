"""
NEOSIRIS - Data Manager
Gestion centralisée des données (CRUD operations)
"""

from datetime import datetime
from PyQt6.QtCore import QObject, pyqtSlot


class DataManager(QObject):
    """Gestionnaire centralisé des opérations CRUD"""
    
    def __init__(self):
        super().__init__()
    
    def _generate_id(self, prefix: str) -> str:
        """Génère un ID unique"""
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S%f")
        return f"{prefix}_{timestamp}"
    
    # ===== PROFILES =====
    
    @pyqtSlot(str, str, str, str, str, result=str)
    def addProfile(self, nom: str, prenom: str, email: str, telephone: str, role: str):
        """Ajoute un profil"""
        profiles = self._load_json("profiles")
        profile_id = self._generate_id("PRF")
        
        profiles[profile_id] = {
            "nom": nom,
            "prenom": prenom,
            "email": email,
            "telephone": telephone,
            "role": role,
            "created": datetime.now().isoformat()
        }
        
        self._save_json("profiles", profiles)
        self.logActivity("👤", "Profil créé", f"{prenom} {nom}")
        self.dataChanged.emit()
        return profile_id
    
    @pyqtSlot(result='QVariantList')
    def getProfiles(self):
        """Retourne tous les profils"""
        profiles = self._load_json("profiles")
        return [{"id": k, **v} for k, v in profiles.items()]
    
    @pyqtSlot(str, result='QVariantMap')
    def getProfile(self, profile_id: str):
        """Retourne un profil spécifique"""
        profiles = self._load_json("profiles")
        return profiles.get(profile_id, {})
    
    @pyqtSlot(str)
    def deleteProfile(self, profile_id: str):
        """Supprime un profil"""
        profiles = self._load_json("profiles")
        if profile_id in profiles:
            nom = f"{profiles[profile_id].get('prenom', '')} {profiles[profile_id].get('nom', '')}".strip()
            del profiles[profile_id]
            self._save_json("profiles", profiles)
            self.logActivity("🗑️", "Profil supprimé", nom)
            self.dataChanged.emit()
    
    # ===== CLIENTS =====
    
    @pyqtSlot(str, str, str, str, str, str, result=str)
    def addClient(self, nom: str, prenom: str, email: str, telephone: str, adresse: str, type_client: str):
        """Ajoute un client"""
        clients = self._load_json("clients")
        client_id = self._generate_id("CLT")
        
        clients[client_id] = {
            "nom": nom,
            "prenom": prenom,
            "email": email,
            "telephone": telephone,
            "adresse": adresse,
            "type": type_client,
            "created": datetime.now().isoformat()
        }
        
        self._save_json("clients", clients)
        self.logActivity("👥", "Client créé", f"{prenom} {nom}")
        self.dataChanged.emit()
        return client_id
    
    @pyqtSlot(result='QVariantList')
    def getClients(self):
        """Retourne tous les clients"""
        clients = self._load_json("clients")
        return [{"id": k, **v} for k, v in clients.items()]
    
    @pyqtSlot(str)
    def deleteClient(self, client_id: str):
        """Supprime un client"""
        clients = self._load_json("clients")
        if client_id in clients:
            nom = f"{clients[client_id].get('prenom', '')} {clients[client_id].get('nom', '')}".strip()
            del clients[client_id]
            self._save_json("clients", clients)
            self.logActivity("🗑️", "Client supprimé", nom)
            self.dataChanged.emit()
    
    # ===== DOSSIERS =====
    
    @pyqtSlot(str, str, str, str, str, result=str)
    def addDossier(self, reference: str, titre: str, client_id: str, type_affaire: str, statut: str):
        """Ajoute un dossier"""
        dossiers = self._load_json("dossiers")
        dossier_id = self._generate_id("DOS")
        
        dossiers[dossier_id] = {
            "reference": reference,
            "titre": titre,
            "client_id": client_id,
            "type_affaire": type_affaire,
            "statut": statut,
            "created": datetime.now().isoformat()
        }
        
        self._save_json("dossiers", dossiers)
        self.logActivity("📁", "Dossier créé", reference)
        self.dataChanged.emit()
        return dossier_id
    
    @pyqtSlot(result='QVariantList')
    def getDossiers(self):
        """Retourne tous les dossiers"""
        dossiers = self._load_json("dossiers")
        return [{"id": k, **v} for k, v in dossiers.items()]
    
    @pyqtSlot(str)
    def deleteDossier(self, dossier_id: str):
        """Supprime un dossier"""
        dossiers = self._load_json("dossiers")
        if dossier_id in dossiers:
            ref = dossiers[dossier_id].get('reference', '')
            del dossiers[dossier_id]
            self._save_json("dossiers", dossiers)
            self.logActivity("🗑️", "Dossier supprimé", ref)
            self.dataChanged.emit()
    
    @pyqtSlot(str)
    def toggleDossierStatut(self, dossier_id: str):
        """Change le statut d'un dossier (Ouvert <-> Fermé)"""
        dossiers = self._load_json("dossiers")
        if dossier_id in dossiers:
            current = dossiers[dossier_id].get('statut', 'Ouvert')
            dossiers[dossier_id]['statut'] = "Fermé" if current == "Ouvert" else "Ouvert"
            
            self._save_json("dossiers", dossiers)
            self.logActivity("🔄", f"Dossier {dossiers[dossier_id].get('reference', '')}", 
                           dossiers[dossier_id]['statut'])
            self.dataChanged.emit()
    
    # ===== ADVERSAIRES =====
    
    @pyqtSlot(str, str, str, str, str, result=str)
    def addAdversaire(self, nom: str, prenom: str, email: str, telephone: str, cabinet: str):
        """Ajoute un adversaire"""
        adversaires = self._load_json("adversaires")
        adv_id = self._generate_id("ADV")
        
        adversaires[adv_id] = {
            "nom": nom,
            "prenom": prenom,
            "email": email,
            "telephone": telephone,
            "cabinet": cabinet,
            "created": datetime.now().isoformat()
        }
        
        self._save_json("adversaires", adversaires)
        self.logActivity("⚔️", "Adversaire créé", f"{prenom} {nom}")
        self.dataChanged.emit()
        return adv_id
    
    @pyqtSlot(result='QVariantList')
    def getAdversaires(self):
        """Retourne tous les adversaires"""
        adversaires = self._load_json("adversaires")
        return [{"id": k, **v} for k, v in adversaires.items()]
    
    @pyqtSlot(str)
    def deleteAdversaire(self, adv_id: str):
        """Supprime un adversaire"""
        adversaires = self._load_json("adversaires")
        if adv_id in adversaires:
            nom = f"{adversaires[adv_id].get('prenom', '')} {adversaires[adv_id].get('nom', '')}".strip()
            del adversaires[adv_id]
            self._save_json("adversaires", adversaires)
            self.logActivity("🗑️", "Adversaire supprimé", nom)
            self.dataChanged.emit()
    
    # ===== MISSIONS =====
    
    @pyqtSlot(str, str, str, str, str, result=str)
    def addMission(self, type_mission: str, titre: str, dossier_id: str, description: str, priority: str):
        """Ajoute une mission"""
        collection = "missions_premium" if type_mission == "premium" else "missions_standard"
        missions = self._load_json(collection)
        mission_id = self._generate_id("MSN")
        
        missions[mission_id] = {
            "titre": titre,
            "dossier_id": dossier_id,
            "description": description,
            "priority": priority,
            "statut": "En cours",
            "created": datetime.now().isoformat()
        }
        
        self._save_json(collection, missions)
        self.logActivity("📋", f"Mission {type_mission} créée", titre)
        self.dataChanged.emit()
        return mission_id
    
    @pyqtSlot(str, result='QVariantList')
    def getMissions(self, type_mission: str):
        """Retourne les missions d'un type"""
        collection = "missions_premium" if type_mission == "premium" else "missions_standard"
        missions = self._load_json(collection)
        return [{"id": k, **v} for k, v in missions.items()]
    
    # ===== PIECES =====
    
    @pyqtSlot(str, str, str, str, result=str)
    def addPiece(self, titre: str, dossier_id: str, type_piece: str, chemin: str):
        """Ajoute une pièce"""
        pieces = self._load_json("pieces")
        piece_id = self._generate_id("PCS")
        
        pieces[piece_id] = {
            "titre": titre,
            "dossier_id": dossier_id,
            "type": type_piece,
            "chemin": chemin,
            "created": datetime.now().isoformat()
        }
        
        self._save_json("pieces", pieces)
        self.logActivity("📎", "Pièce ajoutée", titre)
        self.dataChanged.emit()
        return piece_id
    
    @pyqtSlot(result='QVariantList')
    def getPieces(self):
        """Retourne toutes les pièces"""
        pieces = self._load_json("pieces")
        return [{"id": k, **v} for k, v in pieces.items()]
    
    # ===== LIVRABLES =====
    
    @pyqtSlot(str, str, str, str, result=str)
    def addLivrable(self, titre: str, mission_id: str, type_livrable: str, contenu: str):
        """Ajoute un livrable"""
        livrables = self._load_json("livrables")
        livrable_id = self._generate_id("LVR")
        
        livrables[livrable_id] = {
            "titre": titre,
            "mission_id": mission_id,
            "type": type_livrable,
            "contenu": contenu,
            "created": datetime.now().isoformat()
        }
        
        self._save_json("livrables", livrables)
        self.logActivity("📄", "Livrable créé", titre)
        self.dataChanged.emit()
        return livrable_id
    
    @pyqtSlot(result='QVariantList')
    def getLivrables(self):
        """Retourne tous les livrables"""
        livrables = self._load_json("livrables")
        return [{"id": k, **v} for k, v in livrables.items()]
