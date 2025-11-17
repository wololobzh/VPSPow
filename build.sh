#!/bin/sh
# scanError "message" "file" "bypass"
scanError() {
    if [ -s error.log ] && [ "$(cat error.log)" != "" ]; then
        addToLog "🔴 $1"
        addToDebug "$1" "$2"
        if [ "$3" = true ]; then
            echo "$log"
            printLog
            exit 1
        fi
    else
        addToLog "🟢 $1"
    fi
}

# addToLog "message"
addToLog() {
    log="$log $1"
}

# addToDebug "message" "file"
addToDebug() {
    echo "$2 ($1)" >> debug.log
    cat error.log >> debug.log
    echo "" >> debug.log
    rm error.log
}

printLog() {
    echo ""
    echo "-------------------------"
    echo "⚠️  Rapport d'erreur ⚠️"
    echo ""
    cat debug.log
}

# convertSingleFile "file"
convertSingleFile() {
    # HTML
    if [ -z "$only" ] || [ "$only" = "html" ]; then
        buildHTML "$1"
        scanError "HTML" "$1" false
    fi

    # Slides
    if [ -z "$only" ] || [ "$only" = "slides" ]; then
        # Pass if it's not a module
        case "$1" in
            *"sources/"*"/modules/"*"/"*".adoc") 
                buildSlides "$1"
                scanError "Slides" "$1" false
                ;;
            *)
                addToLog "⚪ Slides"
                ;;
        esac
    fi

    # PDF
    if [ -z "$only" ] || [ "$only" = "pdf" ]; then
        # Pass if it's not a module
        case "$1" in
            *"sources/saisons/"*"/pdf.adoc")
                buildPDF "$1"
                scanError "PDF" "$1" false
                ;;
            *"sources/"*"/modules/"*"/"*".adoc") 
                buildPDF "$1"
                scanError "PDF" "$1" false
                ;;
            *)
                addToLog "⚪ PDF"
                ;;
        esac
    fi
}

# buildHTML "file(s)"
buildHTML() {
    asciidoctor -R sources -D build \
        -r asciidoctor-diagram \
        -r /workspace/adoc/macros/glob-include-processor.rb \
        -a stylesheet=/workspace/adoc/libs/html.css \
        -a mermaid-puppeteer-config=/workspace/puppeteer-config.json \
        -a visible-on-html=yes \
        -a max-include-depth=250 \
        -a data-uri \
        -a allow-uri-read \
        -d book \
        --trace \
        $@ &> error.log
}

# buildSlides "file(s)"
buildSlides() {
    asciidoctor-revealjs -R sources -D build \
        -r asciidoctor-diagram \
        -a mermaid-puppeteer-config=/workspace/puppeteer-config.json \
        -r /workspace/adoc/macros/glob-include-processor.rb \
        -a revealjsdir=https://cdn.jsdelivr.net/npm/reveal.js \
        -a outfilesuffix=-slides.html \
        -a revealjs_customtheme=/slides.css \
        -a highlightjs-theme=https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/rainbow.min.css \
        -a revealjs_theme=moon \
        -a max-include-depth=250 \
        -a revealjs_slideNumber=true \
        -a revealjs_controlsTutorial=true \
        -a revealjs_hash=true \
        -a revealjs_center=false \
        -a revealjs_mouseWheel=false \
        -a revealjs_transitionSpeed=fast \
        -a data-uri \
        -a allow-uri-read \
        $@ &> error.log
}

# buildPDF "file(s)"
buildPDF() {
    asciidoctor-pdf -R sources -D build \
        -r asciidoctor-diagram \
        -r /workspace/adoc/macros/glob-include-processor.rb \
        -a compress \
        -a allow-uri-read \
        -a max-include-depth=250 \
        $@ &> error.log
    # Filter media conversion errors line from error.log
    sed -i '/prawn-gmagick gem/d' error.log
}

##############################
#            MAIN            #
##############################
log=""
echo $log > debug.log


while getopts p:o:d flag
do
    case "${flag}" in
        o) only=${OPTARG};;
        p) path=${OPTARG};;
        d) deploy=true;;
    esac
done

# Si le chemin est vide, on le remplace par sources/
if [ -z "$path" ]; then
    path="sources/"
fi

# Remplace les \ par des /
path=${path//\\//}

# Supprimer le contenu du répertoire build
if [ -z "$only" ] && [ "$path" = "sources/" ]; then
    addToLog "Suppression du contenu obsolète"
    rm -rf build/*
fi

# Copie des dépendances de style
mkdir -p build
cp -r adoc/libs/images build/images
cp -r adoc/libs/font build/font
cp adoc/libs/slides.css build
cp login.html build


# Traiement des fichiers
if [ "$deploy" ]; then
    # Crée des tableaux vides pour stocker les fichiers à traiter
    filesToHTML=""
    filesToSlides=""
    filesToPDF=""
    # Parcours tous les fichiers adoc en partant des sources
    for file in $(find sources/ -name "*.adoc"); do
        case "$file" in
            *"/saisons/"*"/pdf.adoc")
                filesToPDF="$filesToPDF $file"
                filesToHTML="$filesToHTML $file"
                ;;
            *"/modules/"*"/"*".adoc")
                filesToSlides="$filesToSlides $file"
                filesToHTML="$filesToHTML $file"
                ;;
            *)
                filesToHTML="$filesToHTML $file"
                ;;
        esac
    done
    # Convertit tous les fichiers
    if [ -z "$only" ] || [ "$only" = "html" ]; then
        echo "HTML"
        buildHTML $filesToHTML
        scanError "HTML" "multiple" true
    fi

    # Slides
    if [ -z "$only" ] || [ "$only" = "slides" ]; then
        echo "Slides"
        buildSlides $filesToSlides
        scanError "Slides" "multiple" true
    fi
    # PDF
    # if [ -z "$only" ] || [ "$only" = "pdf" ]; then
    #     echo "PDF"
    #     buildPDF $filesToPDF
    #     scanError "PDF" "multiple" true
    # fi
else
    # Parcours tous les fichiers adoc en partant des sources
    for file in $(find sources/ -name "*.adoc"); do
        # Continue if file is not in path
        case "$file" in
            *"$path"*)
                ;;
            *)
                continue
                ;;
        esac
        log="$file -> "
        convertSingleFile "$file"
        echo "$log"
    done
fi

# Gestion des erreurs
if [ -s debug.log ] && [ "$(cat debug.log)" != "" ]; then
    printLog
    exit 1
fi