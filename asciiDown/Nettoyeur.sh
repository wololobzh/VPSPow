#!/bin/bash

# Répertoire de base (le dossier courant)
BASE_DIR="."

# Fonction pour supprimer les contenus entre ^ et ^ dans un fichier
remove_patterns() {
    local file="$1"
    sed -i.bak -e 's/\^.*\^//g' "$file"
    # Supprimer les fichiers de sauvegarde générés par sed
    rm -f "$file.bak"
}

# Parcourir les fichiers .md dans le répertoire et ses sous-répertoires
find "$BASE_DIR" -type f -name "*.md" | while read -r file; do
    echo "Traitement du fichier : $file"
    remove_patterns "$file"
done

echo "Traitement terminé."