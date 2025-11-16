#!bin/bash
function replace() {
    # Replace tag by value with awk
    tag=$1
    value=$2
    echo "Replacing $tag"
    awk -v tag="{{$tag}}" -v value="$value" '{gsub(tag, value)}1' $output > tmp.md
    mv tmp.md $output
}

output="./prompt.md"
if [ -n "$1" ]; then
    output=$1
fi

# Copy md template 
cp ./templates/prompt.md $output

# Get last modified modules recursively
modules=$(ls -t ./sources/*/modules/*/*.adoc | head -2)
index=1
for module in $modules
do
    echo $module
    content=$(cat $module)
    replace "example$index" "$content"
    index=$((index+1))
done

# Read template module.adoc
template=$(cat ./templates/module.adoc)
replace "template" "$template"

# Ask for details
echo ":titre: 
:module: 
:duree: 

Desciption :
" > tmp.md
demande=$(cat tmp.md)
replace "demande" "$demande"


echo "Prompt generated in $output !"
