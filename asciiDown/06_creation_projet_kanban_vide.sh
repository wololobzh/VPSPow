#!/bin/bash

# Nom du fichier de sortie
output_file="structure.json"

# Fonction pour initialiser la structure JSON
initialize_structure() {
  json_content='{
    "name": "s15",
    "columns": [
      {
        "id": "column-1",
        "name": "No Status",
        "cards": []
      }
    ]
  }'

  if echo "$json_content" > "$output_file"; then
    echo "Structure JSON créée avec succès dans le fichier $output_file."
  else
    echo "Erreur lors de la création de la structure JSON."
  fi
}

# Fonction pour ajouter une colonne
add_column() {
  local column_id="$1"
  local column_name="$2"

  jq \
    --arg id "$column_id" \
    --arg name "$column_name" \
    ".columns += [{id: \$id, name: \$name, cards: []}]" \
    "$output_file" > tmp.json && mv tmp.json "$output_file"

  echo "Colonne ajoutée : ID=$column_id, Name=$column_name"
}

# Fonction pour ajouter une carte dans une colonne
add_card() {
  local column_id="$1"
  local card_id="$2"
  local card_content="$3"

  jq \
    --arg column_id "$column_id" \
    --arg card_id "$card_id" \
    --arg content "$card_content" \
    ".columns |= map(if .id == \$column_id then .cards += [{id: \$card_id, content: \$content}] else . end)" \
    "$output_file" > tmp.json && mv tmp.json "$output_file"

  echo "Carte ajoutée dans la colonne $column_id : ID=$card_id, Content=$card_content"
}

# Initialiser la structure JSON
initialize_structure

# Exemple d'utilisation des fonctions
add_column "column-2" "s15e0"
add_card "column-1" "card-1" "# Exemple de contenu pour une carte"



#faire une pause pour voir le résultat
read -n 1 -s -r -p "Appuyez sur une touche pour continuer..."