#!/bin/sh

#Création des contenus au format formateurs

echo -e "\e[32mWelcome\e[0m"

bash ./00_build_test.sh

#ici je supprime les includes
#bash ./01_build_asciiReducer.sh ./../sources/developpeur_expert_js/modules ./../adoc_completed
bash ./01_build_asciiReducer.sh ./../sources/developpeur_front_end/modules ./../adoc_completed

#read -n 1 -s -r -p "Etape 1 (suppression des includes Ok)"

#ici je supprime les note.speaker
bash ./02_build_asciiNoteSpeakerDeleter.sh ./../adoc_completed ./../adoc_completed_without_note_speaker

#read -n 1 -s -r -p "Etape 2 (suppression des Note.Speaker OK)"

#ici je créé les mds
bash ./03_build_mdBuilder.sh ./../adoc_completed_without_note_speaker ./../md_completed_without_note_speaker

#read -n 1 -s -r -p "Etape 3 (Creation des md OK)"

#ici je nettoie les mds
bash ./04_build_mdCleaner.sh ./../md_completed_without_note_speaker ./../md_completed_without_note_speaker_cleaned

#ici je créé les slides
bash ./05_build_slidesBuilder.sh ./../md_completed_without_note_speaker_cleaned ./../slides_completed

#ici je créé les md avec des notes speakers
bash ./03_build_mdBuilder.sh ./../adoc_completed ./../md_completed_with_note_speaker

#read -n 1 -s -r -p "Etape 4 (Creation des Slides OK)"

#supprimer dossier developpeur_front_end_adoc_completed
rm -rf ./../adoc_completed
rm -rf ./../adoc_completed

rm -rf ./../adoc_completed_without_note_speaker
rm -rf ./../md_completed_without_note_speaker
rm -rf ./../md_completed_without_note_speaker_cleaned
