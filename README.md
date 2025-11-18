# Doc as Code

- [Syntaxe Asciidoc](https://docs.asciidoctor.org/asciidoc/latest/syntax-quick-reference/)
- [Doc Mermaid](https://mermaid.js.org/intro/)

## Contribution

### Mise en place

Deux possibilités pour contribuer à la documentation :

- en local (recommandé)
- via Codespace (simple et rapide)

#### Local

Les 2 prérequis pour contribuer sont : 

- avoir Docker installé sur sa machine
- avoir VsCode et l'extension devcontainer

Au premier lancement, il faut ouvrir le repo dans VsCode et cliquer sur le bouton `Reopen in Container`. Cela va construire l'image Docker, lancer le webserver et builder les supports.

A chaque modification d'un fichier `.adoc`, l'exécution RunOnSave va se déclencher et mettre à jour le fichier `.html` correspondant.

> Se rendre sur localhost:8282 pour voir le résultat

Pour forcer le build d'un ou plusieurs éléments, il suffit de lancer les commandes suivantes dans le terminal VsCode :

- `./build.sh` pour tout builder, dans tous les formats
- `./build.sh -p <fichier>` pour builder un fichier spécifique
- `./build.sh -o html` pour builder tous les fichiers en html
- `./build.sh -o pdf` pour builder tous les fichiers en pdf
- `./build.sh -o slides` pour builder tous les fichiers en slides

> Les options `-o` et `-p` sont cumulables

#### Codespace

L'utilisation de Codespace directement depuis Github supprime les dépendances à Docker et VsCode sur la machine hôte.

Le port `8282` est automatiquement redirigé pour avoir la prévisualisation html du contenu.

### Respecter la taxonomie de Bloom

Les objectifs pédagogique de chaque partie (saisons, épisodes et modules) doivent respecter la taxonomie de Bloom. Pour rappel, voici les 6 niveaux de la taxonomie de Bloom :

- **Se rappeler** ; niveau basique de mémorisation de termes ou de concepts
- **Comprendre** ; pouvoir reformuler
- **Appliquer** ; utilisation dans des situations concrètes
- **Analyser** ; décomposition en éléments, identification de relations et de l'importance de chacun
- **Évaluer** ; jugement sur la base de critères ou de normes
- **Créer** ; combinaison d'éléments pour former un tout cohérent et novateur

#### FAQ

l'erreur : build.sh: line 49: syntax error: unexpected word (expecting "in") se resout en remplacant CRLF par LF dans le fichier build.sh 
