"""
NEOSIRIS - Module IA Assistant
Multi-providers support: OpenAI, Anthropic, Gemini, Mistral
"""
from PyQt6.QtCore import QObject, pyqtSlot

class IAModule(QObject):
    def __init__(self):
        super().__init__()
    
    @pyqtSlot(str, result=str)
    def askIA(self, question: str):
        """Répond via IA (simulation pour l'instant)"""
        responses = {
            "requête": "Pour rédiger une requête, structurez en 3 parties: 1) Faits, 2) Droit applicable, 3) Demandes.",
            "document": "L'analyse de document nécessite l'intégration d'une API IA.",
            "contrat": "Pour générer un contrat, précisez le type (vente, prestation, bail).",
            "conseils": "Pour des conseils juridiques personnalisés, consultez un avocat."
        }
        
        question_lower = question.lower()
        for key, response in responses.items():
            if key in question_lower:
                return response
        
        return f"Assistant IA en mode simulation. Question: '{question}'"
    
    @pyqtSlot(str, str, str)
    def saveIAConfig(self, provider: str, api_key: str, model: str):
        """Sauvegarde configuration IA"""
        config = self._load_json("ia_config")
        config[f"{provider}_api_key"] = api_key
        config[f"{provider}_model"] = model
        config[f"{provider}_enabled"] = True
        config["last_provider"] = provider
        self._save_json("ia_config", config)
        self.logActivity("⚙️", f"Config IA: {provider}", model)
        self.dataChanged.emit()
