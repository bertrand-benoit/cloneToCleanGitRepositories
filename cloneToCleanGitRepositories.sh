#!/bin/bash
#
# Author: Bertrand Benoit <mailto:contact@bertrand-benoit.net>
# Version: 1.1
#
# Description: Create clean git repositories for EACH file matching specified filter, from specified source git repository (aka the first catchall one).
# It is very interesting to create proper git repository, with a dedicated history, for your files which are currently all in the same Git repository.
#
# This script uses [scripts-common](https://github.com/bertrand-benoit/scripts-common)

currentDir=$( dirname "$( command -v "$0" )" )
scriptsCommonUtilities="$currentDir/scripts-common/utilities.sh"
[ ! -f "$scriptsCommonUtilities" ] && echo -e "ERROR: scripts-common utilities not found, you must initialize your git submodule once after you cloned the repository:\ngit submodule init\ngit submodule update" >&2 && exit 1
# shellcheck disable=1090
. "$scriptsCommonUtilities"

# usage: usage <name>
function usage() {
  echo -e "Usage: $0 <source repository> <dest root directory> <filter>"
  echo -e "<source repository>\t\tpath to the existing catchall git repository"
  echo -e "<dest root directory>\t\tpath to the existing root directory, in which git repositories will be created"
  echo -e "<filter>\t\t\tthe (find) file pattern for which a git repository must be created"
  echo -e "\nN.B.: the source repository won't be altered in any way"
  echo -e "\nSample:\n$0 /path/to/my/catchall/git/repository /tmp/myFirstTest '*.sh'"

  exit "$ERROR_USAGE"
}

# CLI light management.
[ $# -lt 3 ] && usage
SOURCE_REPO="$1"
[ ! -d "$SOURCE_REPO" ] && errorMessage "Specified source Git repository '$SOURCE_REPO' does not exist."
DEST_ROOT_DIR="$2"
[ ! -d "$DEST_ROOT_DIR" ] && errorMessage "Specified destination root directory '$DEST_ROOT_DIR' does not exist."
FILTER="$3"
[ -z "$FILTER" ] && errorMessage "Specified filter '$FILTER' is NOT valide."

sourceRepoName=$( basename "$SOURCE_REPO" )

# For each file in root of the source git repository.
function cloneToCleanGitRepositories() {
  while IFS= read -r -d '' refToManage; do
    # Safe-guard: refuse .git element path.
    [[ "$refToManage" =~ /.*[.]git.*/ ]] && writeMessage "Ignoring $refToManage because it is part of Git repository metadata." && continue

    writeMessage "Starting management of $refToManage ..."

    refFileName=$( basename "$refToManage" )
    newDestRepo="$DEST_ROOT_DIR/$refFileName"

    # Creates the repository if not existing.
    logFile="$newDestRepo/logFile.txt"
    writeMessage "Creating new repository: '$newDestRepo', Log file: $logFile ... "

    if [ ! -d "$newDestRepo" ]; then
      mkdir -p "$newDestRepo"
      cd "$newDestRepo" || exit "$ERROR_ENVIRONMENT"
      ! git clone -q "$SOURCE_REPO" && errorMessage "Error while cloning source repository to $newDestRepo."
    fi
    cd "$newDestRepo/$sourceRepoName" || exit "$ERROR_ENVIRONMENT"

    # Removes all other resources.
    # NB.: 'Expressions don't expand in single quotes' is EXACTLY what we want here, so disabling shellcheck corresponding warning.
    # shellcheck disable=2016
    FILTER='git ls-tree -r --name-only --full-tree "$GIT_COMMIT" |grep -v ".git" |grep -v "'$refFileName'" |tr "\n" "\0" |xargs --no-run-if-empty -0 git rm -f --cached -r --ignore-unmatch'
    ! git filter-branch -f --prune-empty --tag-name-filter cat --index-filter "$FILTER" -- --all >"$logFile" 2>&1 && errorMessage "Error while cleaning new git repository."

    # Cleans remote information, if any, to ensure there is no push to the source repository.
    [[ $( wc -l < <(git remote ) ) -gt 0 ]] && ! git remote remove origin >>"$logFile" 2>&1 && errorMessage "Error while removing remote."

    writeMessage "Successfully completed management of $refToManage."
  done < <(find "$SOURCE_REPO" -type f -name "$FILTER" -print0)
}

writeMessage "System will create a git repository for each file matching (find filter) '$FILTER', in a sub-directory of '$DEST_ROOT_DIR', from a clone of '$SOURCE_REPO'."
cloneToCleanGitRepositories
writeMessage "System completed all creation (if none has been created, check your filter)."
