#!/bin/bash


CURRENT_FOLDER=$(pwd)
TARGET_FOLDER=$1
VERIFY_EXTENSION=".md5"

die() {
    >&2 echo "FATAL: $1"
    cd ${CURRENT_FOLDER}
    exit 1
}

verify_hash() {
    local file_path
    local current_hash
    local hash_file_path
    file_path=$1
    current_hash=$2
    hash_file_path="${file_path}${VERIFY_EXTENSION}"
    if [ ! -f $hash_file_path ]; then
        return
    fi
    case `grep -Fx "$current_hash" "$hash_file_path" >/dev/null; echo $?` in
    0)
        #echo ">>> HASH match!"
        ;;
    1)
        #echo ">>> HASH mismatch!"
        FAILED_FILE_PATHS+="$file_path [MISMATCH]"
        ;;
    *)
        #echo ">>> VERIFY HASH FAILED!"
        FAILED_FILE_PATHS+="$file_path [ERROR]"
        ;;
    esac
}

create_or_update_hash() {
    local file_path
    local current_hash
    local hash_file_path
    file_path=$1
    current_hash=$2
    hash_file_path="${file_path}${VERIFY_EXTENSION}"
    echo $current_hash > "${hash_file_path}"
}


FAILED_FILE_PATHS=()
cd ${TARGET_FOLDER} || die "Failed to change to target folder!"
for target_file in $(find ${TARGET_FOLDER} -type f)
do
    if [[ $target_file =~ (\/(.git|.hidden)\/|($VERIFY_EXTENSION))+ ]];
    then
        continue
    fi
    # echo "target_file=$target_file"
    CURRENT_HASH=$(shasum $target_file | awk '{ print $1 }')
    verify_hash $target_file $CURRENT_HASH
    create_or_update_hash $target_file $CURRENT_HASH
done
cd ${CURRENT_FOLDER}
TOTAL_FAILED_ITEMS=${#FAILED_FILE_PATHS[@]}
if [ $TOTAL_FAILED_ITEMS == 0 ];
then
    echo "All files passed!"
    exit 0
else
    >&2 echo "Total failures: ${TOTAL_FAILED_ITEMS}"
    >&2 echo ${FAILED_FILE_PATHS[@]}
    exit 1
fi
