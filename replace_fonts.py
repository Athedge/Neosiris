# replace_fonts.py
import re
import shutil
from datetime import datetime

def replace_fonts_in_file(file_path):
    """Remplace tous les ctk.CTkFont par get_font dans un fichier"""
    
    # Faire une sauvegarde
    backup_path = f"{file_path}.backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    shutil.copy2(file_path, backup_path)
    print(f"✅ Sauvegarde créée : {backup_path}")
    
    # Lire le fichier
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    original_content = content
    
    # Liste des remplacements à effectuer
    replacements = [
        # ctk.CTkFont avec size et weight
        (r'ctk\.CTkFont\(size=(\d+),\s*weight="bold"\)', r'get_font(size=\1, weight="bold")'),
        (r'ctk\.CTkFont\(size=(\d+),\s*weight="normal"\)', r'get_font(size=\1, weight="normal")'),
        (r'ctk\.CTkFont\(size=(\d+),\s*weight="light"\)', r'get_font(size=\1, weight="light")'),
        
        # ctk.CTkFont avec seulement size
        (r'ctk\.CTkFont\(size=(\d+)\)', r'get_font(size=\1)'),
        
        # ctk.CTkFont() vide (défaut)
        (r'ctk\.CTkFont\(\)', r'get_font()'),
        
        # font=ctk.CTkFont (cas généraux restants)
        (r'font=ctk\.CTkFont\(', r'font=get_font('),
    ]
    
    # Appliquer les remplacements
    replacements_count = 0
    for pattern, replacement in replacements:
        matches = re.findall(pattern, content)
        if matches:
            content = re.sub(pattern, replacement, content)
            replacements_count += len(matches)
            print(f"  → Remplacé {len(matches)} occurrence(s) de : {pattern}")
    
    # Sauvegarder le fichier modifié
    if content != original_content:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"\n✅ {replacements_count} remplacement(s) effectué(s)")
        print(f"✅ Fichier mis à jour : {file_path}")
    else:
        print("\ℹ️  Aucun remplacement nécessaire")
    
    return replacements_count

if __name__ == "__main__":
    import os
    
    # Chemin du fichier à modifier
    script_dir = os.path.dirname(os.path.abspath(__file__))
    main_file = os.path.join(script_dir, "main.py")
    
    if not os.path.exists(main_file):
        print(f"❌ Erreur : fichier non trouvé : {main_file}")
        print(f"   Assurez-vous que replace_fonts.py est dans le même dossier que main.py")
        input("\nAppuyez sur Entrée pour quitter...")
        exit(1)
    
    print("=" * 60)
    print("REMPLACEMENT DES POLICES DANS LEXIRIS")
    print("=" * 60)
    print(f"\nFichier cible : {main_file}\n")
    
    # Demander confirmation
    response = input("Voulez-vous continuer ? (oui/non) : ").lower().strip()
    
    if response in ['oui', 'o', 'yes', 'y']:
        print("\n🔄 Traitement en cours...\n")
        count = replace_fonts_in_file(main_file)
        
        print("\n" + "=" * 60)
        print("✅ TRAITEMENT TERMINÉ")
        print("=" * 60)
        print(f"\n💡 Une sauvegarde a été créée au cas où")
        print(f"💡 Vous pouvez maintenant lancer Lexiris avec la police Marianne")
    else:
        print("\n❌ Opération annulée")
    
    input("\nAppuyez sur Entrée pour quitter...")