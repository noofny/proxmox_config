import sys
import os
import hashlib
import glob


HASH_FILE_FOLDER = '.md5hash'
HASH_FILE_EXTENSION = '.md5'


def die(error, target_folder):
    print(f'Create file hashes FAILED for : {target_folder} : {error}')
    sys.exit(1)


def get_hash_file_path_from_target_file_path(target_file_path, target_folder):
    hash_file_path = target_file_path.replace(f'{target_folder}/', f'{target_folder}/{HASH_FILE_FOLDER}/')
    return f'{hash_file_path}{HASH_FILE_EXTENSION}'


def get_target_file_path_from_hash_file_path(hash_file_path, target_folder):
    target_file_path = hash_file_path.replace(f'{target_folder}/{HASH_FILE_FOLDER}/', f'{target_folder}/')
    return target_file_path[:-4]


def get_hash_files(target_folder):
    if not os.path.isdir(target_folder):
        return None
    filtered_files = []
    unfiltered_files = glob.glob(f'{target_folder}/{HASH_FILE_FOLDER}/**/*.md5', recursive=True)
    for filename in unfiltered_files:
        if '.DS_Store' in filename:
            continue
        filtered_files.append(filename)
    return filtered_files


def get_target_files(target_folder):
    filtered_files = []
    unfiltered_files = glob.glob(f'{target_folder}/**/*.*', recursive=True)
    for filename in unfiltered_files:
        if filename.endswith(HASH_FILE_EXTENSION):
            continue
        if '.DS_Store' in filename:
            continue
        if f'/{HASH_FILE_FOLDER}/' in filename:
            continue
        filtered_files.append(filename)
    return filtered_files


def remove_orphaned_hash_file(hash_file_path, target_folder):
    target_file_path = get_target_file_path_from_hash_file_path(hash_file_path, target_folder)
    if os.path.isfile(target_file_path):
        return False  # source file still exists
    os.remove(hash_file_path)
    return True


def create_missing_hash_file(target_file_path, target_folder):
    hash_file_path = get_hash_file_path_from_target_file_path(target_file_path, target_folder)
    hash_folder_path = os.path.dirname(hash_file_path)
    if os.path.isfile(hash_file_path):
        return False  # hash file already exists
    if not os.path.isdir(hash_folder_path):
        os.makedirs(hash_folder_path)
    with open(target_file_path, 'rb') as file_handle:
        file_contents = file_handle.read()
        current_hash = hashlib.md5(file_contents).hexdigest()
        with open(hash_file_path, 'w') as file_handle:
            file_handle.write(current_hash)
    return True


def verify_target_file(target_file_path, target_folder):
    hash_file_path = get_hash_file_path_from_target_file_path(target_file_path, target_folder)
    if not os.path.isfile(hash_file_path):
        return False  # no hash file exists
    with open(hash_file_path, 'r') as file_handle:
        previous_hash = file_handle.read()
    with open(target_file_path, 'rb') as file_handle:
        file_contents = file_handle.read()
        current_hash = hashlib.md5(file_contents).hexdigest()
    return previous_hash == current_hash


if __name__ == "__main__":
    target_folder = os.path.abspath(sys.argv[1])
    print(f'Processing script for folder : {target_folder}')
    
    # remove -----------------------------------------------------------------------------
    removed_items = []
    hash_files = get_hash_files(target_folder)
    total_hash_files = len(hash_files)
    print(f'Removing orphaned hash files ({total_hash_files} found)...')
    for filename in hash_files:
        if remove_orphaned_hash_file(filename, target_folder):
            removed_items.append(filename)
    total_items_removed = len(removed_items)
    if total_items_removed > 0:
        print(f'...{total_items_removed} orphaned hashes were removed...')
        print('\n'.join(removed_items))
    else:
        print(f'...no orphaned hashes were removed')

    # create ------------------------------------------------------------------------------
    created_items = []
    target_files = get_target_files(target_folder)
    total_target_items = len(target_files)
    print(f'Creating missing hash files ({total_target_items} found)...')
    for filename in target_files:
        if create_missing_hash_file(filename, target_folder):
            created_items.append(filename)
    total_created_items = len(created_items)
    if total_created_items > 0:
        print(f'...{total_created_items} new hashes were created...')
        print('\n'.join(created_items))
    else:
        print(f'...no new hashes were created')

    # verify -----------------------------------------------------------------------------
    failed_items = []
    target_files = get_target_files(target_folder)
    total_target_items = len(target_files)
    print(f'Verifying existing hash files ({total_target_items} found)...')
    for filename in target_files:
        if not verify_target_file(filename, target_folder):
            failed_items.append(filename)
    total_failed_items = len(failed_items)
    if total_failed_items > 0:
        print(f'...{total_failed_items}/{total_target_items} files failed verification...')
        print('\n'.join(failed_items))
    else:
        print(f'...all {total_target_items} files passed verification')

    print(f'TotalRemoved:{total_items_removed} TotalCreated:{total_created_items} TotalFailed:{total_failed_items}/{total_target_items}')
