#!/bin/bash


TARGET_FOLDER=$(realpath $1)
HASH_FILE_FOLDER=".md5hash"
HASH_FILE_EXTENSION=".md5"



die() {
    >&2 echo "Create file hashes FAILED for : ${TARGET_FOLDER} : $1"
    exit 1
}

get_hash_file_path_from_source_file_path() {
    local source_file_path
    source_file_path="${1}"
    hash_file_path=$(echo "${source_file_path}" | sed "s%${TARGET_FOLDER}%${TARGET_FOLDER}/${HASH_FILE_FOLDER}%g")${HASH_FILE_EXTENSION}
    echo "${hash_file_path}"
}

get_source_file_path_from_hash_file_path() {
    local hash_file_path
    hash_file_path="${1}"
    source_file_path=$(echo "${hash_file_path%.*}" | sed "s%${TARGET_FOLDER}/${HASH_FILE_FOLDER}%${TARGET_FOLDER}%g")
    echo "${source_file_path}"
}

remove_orphaned_hash_file() {
    local hash_file_path
    local source_file_path
    hash_file_path="${1}"
    source_file_path=$(get_source_file_path_from_hash_file_path "${hash_file_path}")
    if [ -f "${source_file_path}" ]; then
        return  # source file still exists
    fi
    echo ">>> deleting hash for non-existing source file!"
    rm -f "${hash_file_path}" || die "Failed to delete orphaned hash file : ${hash_file_path}"
    ACTION_ITEMS+=("${hash_file_path}")
}

create_missing_hash_file() {
    local source_file_path
    local hash_file_path
    local current_hash
    source_file_path="${1}"
    hash_file_path=$(get_hash_file_path_from_source_file_path "${source_file_path}")
    hash_folder_path=$(dirname "${hash_file_path}")
    if [ -f "${hash_file_path}" ]; then
        return  # hash file already exists
    fi
    current_hash=$(shasum "${source_file_path}" | awk '{ print $1 }')
    if ! [ -d "${hash_folder_path}" ];
    then
        mkdir -p "${hash_folder_path}"
    fi
    echo "${current_hash}" > "${hash_file_path}"
    ACTION_ITEMS+=("${hash_file_path}")
}

execute_action() {
    local action
    local target_folder_path
    local file_type_filter
    action="${1}"
    ACTION_ITEMS=()
    if [ "${action}" == "remove_orphaned_hash_file" ];
    then
        target_folder_path="${TARGET_FOLDER}/${HASH_FILE_FOLDER}"
        file_type_filter="-name '*.md5' -not -name '*.DS_Store'"
    else
        target_folder_path="${TARGET_FOLDER}"
        file_type_filter="-not -name '*.md5' -not -name '*.DS_Store'"
    fi
    if [[ "${action}" == "remove_orphaned_hash_file" && ! -d "${target_folder_path}" ]];
    then
        echo "No '${action}' items were actioned for : ${TARGET_FOLDER}"
        return
    fi
    TOTAL_TARGET_ITEMS=0
    find ${target_folder_path} ${file_type_filter} -type f | while read target_file
    do
        if [[ "${action}" == "create_missing_hash_file" && "${target_file}" =~ (\/(${HASH_FILE_FOLDER}|.git|.hidden)\/|(.DS_Store))+ ]];
        then
            continue
        fi
        echo "target_file=$target_file"
        $1 "${target_file}"
        ((TOTAL_TARGET_ITEMS=TOTAL_TARGET_ITEMS+1))
    done
    echo "${TOTAL_ACTION_ITEMS}/${TOTAL_TARGET_ITEMS} '${action}' items were actioned for : ${TARGET_FOLDER}"
    TOTAL_ACTION_ITEMS=${#ACTION_ITEMS[@]}
    if [ $TOTAL_ACTION_ITEMS > 0 ];
    then
        (IFS=$'\n'; echo "${ACTION_ITEMS[*]}")
    fi
}

execute_action remove_orphaned_hash_file
execute_action create_missing_hash_file

exit 0
