#!/usr/bin/env bash

DOTFILES=(.bashrc .bash_profile .bash_aliases .vimrc .gitconfig .gitignore)
SRC_DIR="${HOME}/src"
declare -A REPO_MAP
REPO_MAP=(
#  ["https://github.com/user/repo"]="${SRC_DIR}/repo"
)
for GITHUB_REPO in "${!REPO_MAP[@]}"; do
  DEST_DIR="${REPO_MAP[$GITHUB_REPO]}"
  if [ ! -d "${DEST_DIR}" ]; then
    echo "INFO: Cloning ${GITHUB_REPO} under ${DEST_DIR}"
    git clone "${GITHUB_REPO}" "${DEST_DIR}"
  else
    echo "INFO: Updating ${GITHUB_REPO} already cloned under ${DEST_DIR}"
    ( cd "${DEST_DIR}" && git fetch )
  fi
done

for DOTFILE in "${DOTFILES[@]}"; do
  SRC="${PWD}/${DOTFILE}"
  DEST="${HOME}/${DOTFILE}"
  echo "INFO: Copying ${SRC} to ${DEST}"
  cp -fv "${SRC}" "${DEST}"
done

# Ensure ~/bin exists
mkdir -p "${HOME}/bin"


DISTRO=$(lsb_release -i | awk -F ':' '{print $2}' | xargs)


case "${DISTRO}" in
	Arch)
		./install-arch.sh
		;;
	Debian|Ubuntu)
		./install-debuntu.sh
		;;
	*)
		echo "Can't figure out which distro you're using."
		exit 1
	;;
esac
