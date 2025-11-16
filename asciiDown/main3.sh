#!/bin/bash

#cat "./../sources/developpeur_expert_js/modules/AnalyseEtConception/010-Introduction_analyse_et_conception.adoc"

#cat "./../sources/developpeur_expert_js/modules/index.adoc"

function extract_title() {
    local file_path="$1"

    # Vérification si le fichier existe
    if [[ ! -f "$file_path" ]]; then
        echo "Erreur : Le fichier n'existe pas."
        return 1
    fi

    # Extraction et affichage du contenu après :title:
    grep -E '^:title:' "$file_path" | sed 's/^:title:\s*//'
}

resultat="$(extract_title "../sources/developpeur_expert_js/saisons/02/episodes/05/index.adoc")"

echo $resultat


