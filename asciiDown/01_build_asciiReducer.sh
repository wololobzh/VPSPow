#!/bin/bash

echo -e "\e[31mBienvenue dans Asciidoctor Reducer c'est partie on remplace les includes mon p'tit gars ;) \e[0m"

echo -e "\e[31m*********************************************** \e[0m"
echo -e "\e[31m*        Suppression des includes             * \e[0m"
echo -e "\e[31m*********************************************** \e[0m"

# Vérification de l'installation d'Asciidoctor Reducer
if ! command -v asciidoctor-reducer &> /dev/null
then
    echo "Asciidoctor Reducer n'est pas installé. Installez-le avec : gem install asciidoctor-reducer"
    exit 1
fi

# Définition des dossiers source et de sortie
SOURCE_DIR=${1}
OUTPUT_DIR=${2}

# Crée le dossier output si nécessaire
mkdir -p "$OUTPUT_DIR"*/

# Fonction pour traiter les fichiers
reduce_files() {
    local current_dir=$1
    local target_dir=$2

    for item in "$current_dir"/*; do
        if [ -d "$item" ]; then
            # Si c'est un dossier, recrée le sous-dossier dans le dossier de sortie et continue
            local new_dir="$target_dir/$(basename "$item")"
            mkdir -p "$new_dir"
            reduce_files "$item" "$new_dir"
        elif [[ "$item" == *.adoc ]]; then
            # Si c'est un fichier .adoc, le réduire et sauvegarder dans le dossier de sortie
            local base_name=$(basename "$item")
            local output_file="$target_dir/$base_name"
            asciidoctor-reducer "$item" -o "$output_file"
            echo "Réduit : $item -> $output_file"
        elif [[ "$item" == *.webp || "$item" == *.png || "$item" == *.jpg || "$item" == *.jpeg || "$item" == *.gif ]]; then
            # Si c'est une image, la copier dans le dossier de sortie
            local base_name=$(basename "$item")
            cp "$item" "$target_dir/$base_name"
            echo "Image copiée : $item -> $target_dir/$base_name"
        fi
    done
}

# Lancer la réduction
reduce_files "$SOURCE_DIR" "$OUTPUT_DIR"

echo "Réduction terminée. Les fichiers réduits sont dans le dossier : $OUTPUT_DIR"