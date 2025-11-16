#!/bin/bash

extract_topic_with_assets() {
    local path="$1"
    echo "$path" | cut -d'/' -f4-5
}

extract_topic() {
    local path="$1"
    echo "$path" | awk -F'/' '{print $4}'
}

echo -e "\e[34m*********************************************** \e[0m"
echo -e "\e[34m*        Création des slides                  * \e[0m"
echo -e "\e[34m*********************************************** \e[0m"

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

BLEU='\033[38;2;0;0;255m'

# Parcours tous les fichiers .md dans le dossier et les sous-dossiers
find "$DOSSIER_ENTREE" -type f -name "*.md" | while read -r FICHIER; do
    # Chemin relatif du fichier par rapport au dossier d'entrée
    CHEMIN_RELATIF="${FICHIER#$DOSSIER_ENTREE/}"
    
    # Chemin complet pour le fichier de sortie
    FICHIER_SORTIE="$DOSSIER_SORTIE/$CHEMIN_RELATIF"

    # recuperation du nom du fichier
    nomFichier=$(basename "$FICHIER")
    basename="${nomFichier%.*}"
    BON_DOSSIER="$DOSSIER_SORTIE/__SAISON__/$basename/$nomFichier"

    # Crée les sous-dossiers nécessaires dans le dossier de sortie
    mkdir -p "$(dirname "$BON_DOSSIER")"

    echo "Traitement du fichier : $FICHIER -> $BON_DOSSIER"

    # Applique la transformation au fichier
    # sed -E 's/^(###? ?.*)/\n---\n\n\1/' "$FICHIER" > "$BON_DOSSIER"
    sed -E -e 's/^(###? ?.*)/\n---\n\n\1/' -e 's#\./assets#./../assets#g' "$FICHIER" > "$BON_DOSSIER"

    echo "Transformation en slide terminée pour : $FICHIER"

    echo -e "${BLEU} \t\t FICHIER : $FICHIER ${RESET}"
    echo -e "${BLEU} \t\t nomFichier : $nomFichier ${RESET}"
    echo -e "${BLEU} \t\t BON_DOSSIER : $BON_DOSSIER ${RESET}"
    echo -e "${BLEU} \t\t FICHIER_SORTIE : $FICHIER_SORTIE ${RESET}"

done

ORANGE='\033[38;2;255;165;0m'

    # Parcours tous les fichiers et sous-dossiers
        for dossier in "$DOSSIER_ENTREE"/*; do

            for item in "$dossier"/*; do
        
                if [ -d "$item" ]; then

                    # Permet de copier les assets dans le dossier de sortie
                    dossierTmp=$(extract_topic "$item")
                    # Si c'est un dossier, créer un sous-dossier correspondant et le parcourir
                    new_dir="$DOSSIER_SORTIE/__SAISON__"
                    #new_dir="$DOSSIER_SORTIE/$dossierTmp"
                    mkdir -p "$new_dir"

                    cp -r "$item" "$new_dir/"

                    echo -e "${ORANGE} \t\t DOSSIER_ENTREE : $DOSSIER_ENTREE ${RESET}"
                    echo -e "${ORANGE} \t\t item : $item ${RESET}"
                    echo -e "${ORANGE} \t\t new_dir : $new_dir ${RESET}"
                    echo -e "${ORANGE} \t\t dossierTmp : $dossierTmp ${RESET}"

                elif [[ "$item" == *.webp || "$item" == *.png || "$item" == *.jpg || "$item" == *.jpeg || "$item" == *.gif ]]; then
                    # Si c'est une image, la copier dans le dossier de sortie
                    base_name=$(basename "$item")
                    #cp "$item" "$DOSSIER_SORTIE/$base_name"
                    cp "$item" "$DOSSIER_SORTIE/__SAISON__"
                    echo "Image copiée : $item -> $DOSSIER_SORTIE/$base_name"
                fi
            done
        done

echo "Traitement terminé. Fichiers transformés enregistrés dans : $DOSSIER_SORTIE"