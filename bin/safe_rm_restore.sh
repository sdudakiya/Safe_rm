#!/bin/bash

file=$1
matchentry=$(cat $HOME/.restore.info |grep -w ^$1)

# the original address of the file
fileOrigin=$(echo -n $matchentry | cut -d":" -f2)

writeFile() {
    originalDir=$(dirname $fileOrigin)
    if [ ! -d $originalDir ] ; then
        mkdir -p $originalDir
    fi
    mv -f $recyclepath/$file $fileOrigin
    grep -v $matchentry $HOME/.restore.info > $HOME/.RMtemp
    mv -f $HOME/.RMtemp $HOME/.restore.info
}

selectCase() {
    case $response in
        y) writeFile ;;
        yes)writeFile;;
        n) exit ;;
        no) exit ;;
        *) "Error: Invalid response!" exit ;;
    esac
}

convertToLower() {
    response=$(echo $response | tr [:upper:] [:lower:])
}

# If the file does not exist in the recycle bin, then produce an error.
if [ ! $matchentry ] ; then
    echo "Error: The file $file does not exist!"
else
    # If the file already exists in the target directory, prompt "Do you want to overwrite?"
    if [ -e $fileOrigin ] ; then
        echo "Do you want to overwrite? $fileOrigin"
        echo "If no, then the file name $file will be used instead of the original name."
        read -p "[Y/n] " response
        convertToLower
        selectCase
    else
        writeFile
    fi
fi
