#!/bin/bash


TARGET_FOLDER=$1
HASH_FILE_EXTENSION=".md5"


die() {
    echo "Verify file hashes FAILED for : ${TARGET_FOLDER} : $1"
    exit 1
}

verify_hash() {
    local file_path
    local current_hash
    local hash_file_path
    file_path=$1
    current_hash=$(shasum $target_file | awk '{ print $1 }')
    hash_file_path="${file_path}${HASH_FILE_EXTENSION}"
    if [ ! -f $hash_file_path ]; then
        return
    fi
    if ! grep -Fx "$current_hash" "$hash_file_path" >/dev/null;
    then
        echo ">>> FAIL=${file_path}"
        FAILED_FILE_PATHS+=(${file_path})
    fi
}

TOTAL_VERIFIED_ITEMS=0
FAILED_FILE_PATHS=()
for target_file in $(find ${TARGET_FOLDER} -type f)
do
    if [[ $target_file =~ (\/(.git|.hidden)\/|($HASH_FILE_EXTENSION)|(.DS_Store))+ ]];
    then
        continue
    fi
    # echo "target_file=$target_file"
    verify_hash $target_file
    ((TOTAL_VERIFIED_ITEMS=TOTAL_VERIFIED_ITEMS+1))
done
TOTAL_FAILED_ITEMS=${#FAILED_FILE_PATHS[@]}
if [ $TOTAL_FAILED_ITEMS == 0 ];
then
    echo "All ${TOTAL_VERIFIED_ITEMS} files passed!"
    exit 0
else
    echo "${TOTAL_FAILED_ITEMS}/${TOTAL_VERIFIED_ITEMS} files failed!"
    (IFS=$'\n'; echo "${FAILED_FILE_PATHS[*]}")
    exit 1
fi
