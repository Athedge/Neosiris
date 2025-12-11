# increase_font_sizes.py
import re
import shutil
from datetime import datetime

def increase_font_sizes(file_path, increase_by=2):
    """Augmente toutes les tailles de police de X points"""
    
    # Faire une sauvegarde
    backup_path = f"{file_path}.backup_fontsize_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(file_path, backup_path)
    print(f"✅ Sauvegarde créée : {backup_path}")
    
    # Lire le fichier
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    original_content = content
    
    # Fonction pour augmenter la taille
    def increase_size(match):
        current_size = int(match.group(1))
        new_size = current_size + increase_by
        return f"size={new_size}"
    
    # Remplacer toutes les occurrences de size=X
    content = re.sub(r'size=(\d+)', increase_size, content)
    
    # Compter les changements
    changes = len(re.findall(r'size=\d+', original_content))
    
    # Sauvegarder
    if content != original_content:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"\n✅ {changes} taille(s) de police augmentée(s) de +{increase_by}")
    else:
        print("\nℹ️  Aucun changement nécessaire")

if __name__ == "__main__":
    import os
    script_dir = os.path.dirname(os.path.abspath(__file__))
    main_file = os.path.join(script_dir, "src", "Lexiris", "main.py")
    
    if not os.path.exists(main_file):
        print(f"❌ Erreur : fichier non trouvé : {main_file}")
        exit(1)
    
    print("=" * 60)
    print("AUGMENTATION DES TAILLES DE POLICE")
    print("=" * 60)
    print(f"Fichier : {main_file}")
    print(f"Augmentation : +2 points\n")
    
    response = input("Continuer ? (oui/non) : ").lower().strip()
    
    if response in ['oui', 'o', 'yes', 'y']:
        print("\n🔄 Traitement...\n")
        increase_font_sizes(main_file, increase_by=2)
        print("\n✅ TERMINÉ")
    else:
        print("\n❌ Annulé")
    
    input("\nAppuyez sur Entrée...")