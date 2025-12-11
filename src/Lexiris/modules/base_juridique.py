"""
NEOSIRIS - Module Base Juridique
Bibliothèque juridique avec format .lexdoc propriétaire
"""
from PyQt6.QtCore import QObject

class BaseJuridiqueModule(QObject):
    def __init__(self):
        super().__init__()
