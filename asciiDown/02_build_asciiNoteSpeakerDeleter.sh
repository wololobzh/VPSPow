#!/bin/bash



extract_topic_with_assets() {
    local path="$1"
    echo "$path" | cut -d'/' -f4-5
}

extract_topic() {
    local path="$1"
    echo "$path" | awk -F'/' '{print $4}'
}

echo "Yo mon job c'est de supprimer les note speaker dans les fichiers adoc"

echo -e "\e[32m*********************************************** \e[0m"
echo -e "\e[32m*        Suppression des notes                * \e[0m"
echo -e "\e[32m*********************************************** \e[0m"

#Pour que ça marche les NOTE.Speaker doivent etre utilis avec des ====

# Vérifie que les arguments d'entrée et de sortie sont fournis
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dossier_entree dossier_sortie"
    exit 1
fi

DOSSIER_ENTREE="$1"
DOSSIER_SORTIE="$2"

# Vérifie si le dossier d'entrée existe
if [ ! -d "$DOSSIER_ENTREE" ]; then
    echo "Le dossier d'entrée n'existe pas : $DOSSIER_ENTREE"
    exit 1
fi

# Crée le dossier de sortie s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"

# Parcourt tous les fichiers .adoc dans le dossier et ses sous-dossiers
find "$DOSSIER_ENTREE" -type f -name "*.adoc" | while read -r FICHIER; do
    # Chemin relatif du fichier par rapport au dossier d'entrée
    CHEMIN_RELATIF="${FICHIER#$DOSSIER_ENTREE/}"
    
    # Chemin complet pour le fichier de sortie
    FICHIER_SORTIE="$DOSSIER_SORTIE/$CHEMIN_RELATIF"

    # Crée les sous-dossiers nécessaires dans le dossier de sortie
    mkdir -p "$(dirname "$FICHIER_SORTIE")"

    #echo "Traitement du fichier : $FICHIER -> $FICHIER_SORTIE"

    # Supprime tout ce qui se trouve entre [NOTE.speaker], ==== et le dernier ====
    awk '
    BEGIN { in_note = 0 }
    /^\[NOTE\.speaker\]$/ { in_note = 1; next }  # Début du bloc [NOTE.speaker]
    in_note && /^====$/ { if (block_start) { in_note = 0; block_start = 0; next } else { block_start = 1; next } }
    in_note { next }                             # Ignore les lignes à l’intérieur du bloc
    !in_note { print }                          # Imprime les lignes hors bloc
    ' "$FICHIER" > "$FICHIER_SORTIE"

    echo "Transformation terminée pour : $FICHIER"
done

ORANGE='\033[38;2;255;165;0m'



    # Parcours tous les fichiers et sous-dossiers
        for dossier in "$DOSSIER_ENTREE"/*; do

            for item in "$dossier"/*; do
        
                if [ -d "$item" ]; then

                    # Permet de copier les assets dans le dossier de sortie
                    dossierTmp=$(extract_topic "$item")
                    # Si c'est un dossier, créer un sous-dossier correspondant et le parcourir
                    new_dir="$DOSSIER_SORTIE/$dossierTmp"
                    mkdir -p "$new_dir"

                    cp -r "$item" "$new_dir/"

                    echo -e "${ORANGE} \t\t DOSSIER_ENTREE : $DOSSIER_ENTREE ${RESET}"
                    echo -e "${ORANGE} \t\t item : $item ${RESET}"
                    echo -e "${ORANGE} \t\t new_dir : $new_dir ${RESET}"
                    echo -e "${ORANGE} \t\t dossierTmp : $dossierTmp ${RESET}"

                elif [[ "$item" == *.webp || "$item" == *.png || "$item" == *.jpg || "$item" == *.jpeg || "$item" == *.gif ]]; then
                    # Si c'est une image, la copier dans le dossier de sortie
                    base_name=$(basename "$item")
                    cp "$item" "$DOSSIER_SORTIE/$base_name"
                    echo "Image copiée : $item -> $DOSSIER_SORTIE/$base_name"
                fi
            done
        done

echo "Traitement terminé. Fichiers transformés enregistrés dans : $DOSSIER_SORTIE"
