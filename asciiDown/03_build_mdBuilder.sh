#!/bin/sh


echo -e "\e[33m*********************************************** \e[0m"
echo -e "\e[33m*        Création des md                      * \e[0m"
echo -e "\e[33m*********************************************** \e[0m"

# Vérifie si downdoc est installé
if ! command -v downdoc &> /dev/null
then
    echo "Le package downdoc n'est pas installé. Installez-le avec 'npm install -g downdoc'."
    read -n 1 -s -r -p "Appuyez sur une touche pour quitter"
    exit 1
fi

# Dossier source et dossier cible
SOURCE_DIR=${1:-"./"}
OUTPUT_DIR=${2:-"./output"}

# Crée le dossier output si nécessaire
mkdir -p "$OUTPUT_DIR"

# Fonction de conversion
convert_files() {
    local current_dir=$1
    local target_dir=$2

    # Parcours tous les fichiers et sous-dossiers
    for item in "$current_dir"/*; do
        if [ -d "$item" ]; then
            # Si c'est un dossier, créer un sous-dossier correspondant et le parcourir
            local new_dir="$target_dir/$(basename "$item")"
            mkdir -p "$new_dir"
            convert_files "$item" "$new_dir"
        elif [[ "$item" == *.adoc ]]; then
            # Si c'est un fichier .adoc, le convertir en .md
            local base_name=$(basename "$item" .adoc)
            local output_file="$target_dir/$base_name.md"
            npx downdoc "$item" -o "$output_file"
            echo "Converti: $item -> $output_file"
        elif [[ "$item" == *.webp || "$item" == *.png || "$item" == *.jpg || "$item" == *.jpeg || "$item" == *.gif ]]; then
            # Si c'est une image, la copier dans le dossier de sortie
            local base_name=$(basename "$item")
            cp "$item" "$target_dir/$base_name"
            echo "Image copiée : $item -> $target_dir/$base_name"
        fi
    done


}

# Lancer la conversion
convert_files "$SOURCE_DIR" "$OUTPUT_DIR"

echo "Conversion terminée. Les fichiers Markdown sont dans le dossier: $OUTPUT_DIR"
