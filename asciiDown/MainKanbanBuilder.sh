#!/bin/bash

### Script de création de KANBANs pour les formateurs ###

# Couleur orange en RGB : 255, 165, 0
ORANGE='\033[38;2;255;165;0m'
VIOLET='\033[38;5;93m'
BLEU='\033[38;2;0;0;255m'
RESET='\033[0m'

rm -rf ./build__TEST

mkdir build__TEST

# Définition des variables principales
output_dir="build__TEST"  # Répertoire de sortie pour les fichiers JSON
source_dir="../sources/developpeur_front_end"  # Répertoire racine des fichiers sources
#source_dir="../sources/developpeur_expert_js"  # Répertoire racine des fichiers sources
data_file="$output_dir/projects.json"  # Fichier JSON principal
#base_url="https://github.com/O-clock-Expert-Dev/Trames/blob/master"  # Base pour générer des URL GitHub
#base_slide="https://github.com/O-clock-Expert-Dev/Slides/blob/main/slides/" # URL des slides

base_url="https://github.com/developpeur_expert_js/Trames/blob/master"  # Base pour générer des URL GitHub
#Chemin à remplacé par le chemin du site des slides
base_slide="https://effective-adventure-2k19mkq.pages.github.io/" # URL des slides


### Fonction pour avoir le chemin des slides ###
transform_path() {
    local input_path="$1"
    # Extraire le nom du dossier contenant le fichier et le nom de fichier sans extension
    local dir_name=$(basename "$(dirname "$input_path")")
    local file_name=$(basename "$input_path" .adoc)
    # Construire le nouveau chemin avec extension .md
    echo "${dir_name}/${file_name}.md"
}

### Fonction pour initialiser le fichier JSON principal ###
initialize_file() {
  echo -e "\e[32m Initialisation du fichier JSON principal $data_file \e[0m"
  cat > "$data_file" <<EOF
{
  "index": 3,
  "projects": []
}
EOF
  echo -e "\e[32m Fichier initialisé avec succès ! \e[0m"
}

### Fonction pour ajouter un projet au fichier JSON principal ###
add_project() {
  local project_id=$1
  local project_name=$2
  local project_description=$3
  local project_file=$4

  echo -e "\e[35m 🌟🌟🌟 Création d'un nouveau KANBAN $project_name \e[0m"

  local new_project=$(jq -n \
    --arg id "$project_id" \
    --arg name "$project_name" \
    --arg desc "$project_description" \
    --arg file "$project_file" \
    '{id: $id, name: $name, description: $desc, file: $file}')

  jq --argjson project "$new_project" '.projects += [$project]' "$data_file" > tmp.json && mv tmp.json "$data_file"
}

### Fonction pour extraire un nom de module à partir d'un chemin ###
extraire_nom_module() {
  local filename="$1"

  # Supprimer le prefixe "include-" et l'extension ".adoc"
  local cleaned_name=$(echo "$filename" | sed 's/^include-//; s/\.adoc$//')

  # Ajouter des espaces avant chaque majuscule sauf la première
  local with_spaces=$(echo "$cleaned_name" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')

  # Remplacer les tirets et les underscores par des espaces
  local formatted=$(echo "$with_spaces" | sed 's/[-_]/ /g')

  # Mettre en majuscule la première lettre de chaque mot
  local title=$(echo "$formatted" | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

  # Supprimer les chiffres au début du titre
  local final_title=$(echo "$title" | sed 's/^\s*[0-9]*\s*//')

  echo "$final_title"
}

### Fonction pour initialiser un fichier JSON spécifique ###
initialize_json() {
  local season_name="$1"
  local output_file="$2"
  echo "{  \"name\": \"$season_name\",  \"columns\": []}" > "$output_file"
  echo -e "\e[32m ✔️ Fichier JSON créé : $output_file $season_name \e[0m"
}

### Fonction pour ajouter une colonne dans un fichier JSON ###
add_column() {
  local output_file="$1"
  local column_id="$2"
  local column_name="$3"
  echo -e "\e[33m 📌 Création de l'épisode numéro $column_name \e[0m"
  jq \
    --arg id "$column_id" \
    --arg name "$column_name" \
    ".columns += [{id: \$id, name: \$name, cards: []}]" \
    "$output_file" > tmp.json && mv tmp.json "$output_file"
}


### Fonction pour ajouter une carte dans une colonne ###
# $1 : fichier JSON
# $2 : ID de la colonne
# $3 : ID de la carte
# $4 : Contenu de la carte
add_card() {
  local output_file="$1"
  local column_id="$2"
  local card_id="$3"
  local card_content="$4"
  
  jq \
    --arg column_id "$column_id" \
    --arg card_id "$card_id" \
    --arg content "$card_content" \
    ".columns |= map(if .id == \$column_id then .cards += [{id: \$card_id, content: \$content}] else . end)" \
    "$output_file" > tmp.json && mv tmp.json "$output_file"
}

### Fonctions spécifiques pour ajouter des cartes préfixées ###
add_challenge_card() {
  local output_file="$1"
  local column_id="$2"
  local card_content="$3"

  local cleaned_content=$(echo "$card_content" | sed 's/:challenge://g' | sed 's/:description:/\n/g' | sed ':a;N;$!ba;s/\\n/\n/g')

  # Ne pas créer de carte si le contenu nettoyé est inférieur à 5 caractères
  if [[ ${#cleaned_content} -lt 5 ]]; then
    echo -e "\e[31m \t 🔴  WARNING - Carte challenge non créée. \e[0m"
    return
  fi

  local prefixed_content="## 💥 Challenge
  
  $cleaned_content"

  add_card "$output_file" "$column_id" "challenge-card" "$prefixed_content"
}

add_intro_card() {
  echo -e "\e[36m \t 🟢 Création de l'introduction \e[0m"
  local output_file="$1"
  local column_id="$2"
  local card_content="$3"
  local prefixed_content="## ⭐ Introduction
  
$card_content"
  add_card "$output_file" "$column_id" "intro-card" "$prefixed_content"
}

add_objectives_card() {
  echo -e "\e[36m \t 🟢 Création des objectifs \e[0m"
  local output_file="$1"
  local column_id="$2"
  local card_content="$3"
  local prefixed_content="## 🚀 Objectifs
  
$card_content"
  add_card "$output_file" "$column_id" "objectives-card" "$prefixed_content"
}

add_prerequisites_card() {
  echo -e "\e[36m \t 🟢 Création du Disclaimer \e[0m"
  local output_file="$1"
  local column_id="$2"
  local card_content="$3"
  local prefixed_content="## ⚠️ Disclaimer
  
$card_content"
  add_card "$output_file" "$column_id" "prerequisites-card" "$prefixed_content"
}

add_atelier_transverse_card() {
  echo -e "\e[36m \t 🟢 Création de la préparation aux ateliers Transverses \e[0m"
  local output_file="$1"
  local column_id="$2"
  local card_content="$3"
  local prefixed_content="## ⏰ Ateliers Transverses
  
Pensez à préparer les ateliers transverses pour demain."
  add_card "$output_file" "$column_id" "prerequisites-card" "$prefixed_content"
}

add_correction_card() {
  local output_file="$1"
  local column_id="$2"
  local card_content="$3"
  local cleaned_content=$(echo "$card_content" | sed 's/:correction://g')
  if [[ -z "$cleaned_content" ]]; then
    echo -e "\e[31m \t 🔴  WARNING - Carte correction non créée : contenu vide. \e[0m"
    return
  fi
  local prefixed_content="## 🏆 Correction
  
$cleaned_content"
  add_card "$output_file" "$column_id" "correction-card" "$prefixed_content"
}

### Fonction pour convertir un chemin relatif en URL GitHub ###
convert_to_github_url() {
  local include_path="$1"
  local folder_name=$(basename $(dirname "$include_path"))
  local file_name=$(basename "$include_path")
  echo "$base_url/$folder_name/$file_name" | sed 's/\.adoc$/.md/'
}

### Fonction pour extraire une section spécifique dans un fichier adoc ###
extract_section() {
  local input_file="$1"
  local tag="$2"
  awk "/\/\/ tag::${tag}\[\]/{flag=1;next}/\/\/ end::${tag}\[\]/{flag=0}flag" "$input_file"
}

### Fonction pour extraire le titre ###
function extract_title() {
    local file_path="$1"

    # Vérification si le fichier existe
    if [[ ! -f "$file_path" ]]; then
        echo "😈 Erreur - Le fichier n'existe pas."
        return 1
    fi

    # Extraction et affichage du contenu après :title:
    grep -E '^:title:' "$file_path" | sed 's/^:title:\s*//'
}

### Fonction qui supprime la partie "../../../../" d'une chaîne de caractères
remove_prefix() {
    local input_path="$1"
    # Supprime la partie "../../../../" au début de la chaîne
    local result="${input_path#../../../../}"
    echo "$result"
}

### Fonction pour extraire la valeur après la clé ":duree:"
function extract_duree() {
    local fichier=$1

    # Vérifie si le fichier existe
    if [[ ! -f "$fichier" ]]; then
        echo "Le fichier spécifié n'existe pas."
        return 1
    fi

    # Recherche la ligne contenant ":duree:" et extrait la valeur
    local duree=$(grep '^:duree:' "$fichier" | sed 's/^:duree: //')

    # Vérifie si une valeur a été trouvée
    if [[ -n "$duree" ]]; then
        echo "$duree"
    else
        echo "😈 ERROR - Aucune durée trouvée dans le fichier."
        return 1
    fi
}

echo -e "\e[32m ############################# \e[0m"
echo -e "\e[32m ### CREATION DES KANBANs #### \e[0m"
echo -e "\e[32m ############################# \e[0m"

initialize_file

for season in "$source_dir"/saisons/*; do
  if [ -d "$season" ]; then
    season_name=$(basename "$season")
    output_file="$output_dir/$season_name.json"
    adoc_file="$season/index.adoc"
    title=$(grep '^:title:' "$adoc_file" | cut -d ' ' -f2-)
    intro_content=$(extract_section "$adoc_file" intro)

    add_project "$season_name" "$season_name - $title" "$intro_content" "$season_name.json"
    initialize_json "$season_name" "$output_file"

    add_column "$output_file" "00" "Notes - Infos - Préparation"

    legende_content="## Légende des icônes
- :heavy_check_mark: OK
- :white_check_mark: Perfectible
- :hourglass_flowing_sand: En test
- :warning: Journée compliquée
- :rotating_light: WIP"

    add_card "$output_file" "00" "legende-card" "$legende_content"

    prepa_content="## 📝 Préparation
- [ ] Lire les trames
- [ ] Lire les slides
- [ ] Lire les challenges
- [ ] Lire les corrections"

    add_card "$output_file" "00" "prepa-card" "$prepa_content"

    changelog_content="## 💫 Changelog
**Version actuelle** : 1.0.0"

    add_card "$output_file" "00" "changelog-card" "$changelog_content"
    
    for episode in "$season"/episodes/*; do
      if [ -d "$episode" ]; then
        episode_name=$(basename "$episode")
        column_id="$episode_name"

        index_file="$episode/index.adoc"

        titre="$(extract_title "$index_file")"

        #echo -e "${BLEU} XXXXX $titre"

        add_column "$output_file" "$column_id" "$episode_name - $titre"
        
        if [ -f "$index_file" ]; then
          add_intro_card "$output_file" "$column_id" "$(extract_section "$index_file" intro)"
          add_objectives_card "$output_file" "$column_id" "$(extract_section "$index_file" objectifs)"
          add_prerequisites_card "$output_file" "$column_id" "$(extract_section "$index_file" prerequis)"
          add_correction_card "$output_file" "$column_id" "$(extract_section "$index_file" deroulement | grep ':correction:')"

          

          while IFS= read -r include_line; do
            include_path=$(echo "$include_line" | sed -n 's/^include::\(.*\)\[.*$/\1/p')
            if [[ -n "$include_path" && ! "$include_path" =~ "header-episode.adoc" && ! "$include_path" =~ "suivi.adoc" && ! "$include_path" =~ "intro-challenge.adoc" && ! "$include_path" =~ "intro-correction.adoc" ]]; then
              github_url=$(convert_to_github_url "$include_path")
              nom_module=$(extraire_nom_module "include-$(basename "$include_path")")
             
              #result=$(transform_path "$include_path")
              result=""
              raccourci=$(remove_prefix "$include_path")
              #echo -e "${BLEU} ${source_dir}${raccourci}"
              #cat ${source_dir}/${raccourci}
              #recuperer la durée du chemin du dessus pour ensuite lafficher dans la carte TODO
              #extract_duree ${source_dir}/${raccourci}

              duree=$(extract_duree "${source_dir}/${raccourci}")

              echo -e "\e[32m \t Création d'une carte : $nom_module \e[0m"
              echo -e "${BLEU} \t\t Duree = $duree"
              echo -e "${ORANGE} \t\t Nom de la carte : $nom_module ${RESET}"
              echo -e "${VIOLET} \t\t Dossier Slide : ${base_slide}${result} ${RESET}"
              add_card "$output_file" "$column_id" "include-$(basename "$include_path")" "### 🧩$nom_module

⏱ $duree minutes

📜 [Pas à pas]($github_url)

▷ [Slides](${base_slide}${result})"
            fi
          done < <(grep '^include::' "$index_file")

          challenge_content="$(grep '^:challenge:' "$index_file")\n$(extract_section "$index_file" deroulement | grep ':description:')"
          add_challenge_card "$output_file" "$column_id" "$challenge_content"

          if (( 10#$column_id % 4 == 0 )); then
            add_atelier_transverse_card "$output_file" "$column_id" "NULL"
          fi
        fi
      fi
    done
  fi
done

echo "Traitement terminé. Les fichiers JSON sont disponibles dans le répertoire $output_dir."
read -n 1 -s -r -p "Appuyez sur une touche pour continuer..."
