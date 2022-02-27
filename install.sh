#!/bin/bash

if [ ${UID} -eq 0 ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="${HOME}/.local/share/icons"
fi

readonly SRC_DIR=$(cd $(dirname $0) && pwd)

readonly COLOR_VARIANTS=("standard" "black" "blue" "brown" "green" "grey" "orange" "pink" "purple" "red" "yellow" "manjaro" "ubuntu" "nord")
readonly BRIGHT_VARIANTS=("" "dark")

usage() {
cat << EOF
Usage: $0 [OPTION] | [COLOR VARIANTS]...

OPTIONS:
  -a                       Install all color folder versions
  -c                       Install circular folder version
  -d DIR                   Specify theme destination directory (Default: $HOME/.local/share/icons)
  -n NAME                  Specify theme name (Default: Tela-circle)
  -h                       Show this help

COLOR VARIANTS:
  standard                 Standard color folder version
  black                    Black color folder version
  blue                     Blue color folder version
  brown                    Brown color folder version
  green                    Green color folder version
  grey                     Grey color folder version
  orange                   Orange color folder version
  pink                     Pink color folder version
  purple                   Purple color folder version
  red                      Red color folder version
  yellow                   Yellow color folder version
  manjaro                  Manjaro default color folder version
  ubuntu                   Ubuntu default color folder version
  nord                     nord color folder version

  By default, only the standard one is selected.
EOF
}

install_theme() {
  # Appends a dash if the variables are not empty
  if [[ "$1" != "standard" ]]; then
    local -r colorprefix="-$1"
  fi

  if [[ "${circle}" == 'true' ]]; then
    local -r folderstyle="-circle"
  else
    local -r folderstyle="-normal"
  fi

  local -r brightprefix="${2:+-$2}"

  local -r THEME_NAME="${NAME}${colorprefix}${brightprefix}"
  local -r THEME_DIR="${DEST_DIR}/${THEME_NAME}"

  if [ -d "${THEME_DIR}" ]; then
    rm -r "${THEME_DIR}"
  fi

  echo "Installing '${THEME_NAME}'..."

  install -d "${THEME_DIR}"

  install -m644 "${SRC_DIR}/src/index.theme"                                     "${THEME_DIR}"

  # Update the name in index.theme
  sed -i "s/%NAME%/${THEME_NAME//-/ }/g"                                         "${THEME_DIR}/index.theme"

  if [ -z "${brightprefix}" ]; then
    cp -r "${SRC_DIR}"/src/{16,22,24,32,symbolic}                                "${THEME_DIR}"
    mkdir -p                                                                     "${THEME_DIR}/scalable"
    cp -r "${SRC_DIR}"/src/scalable/{apps,devices,mimetypes}                     "${THEME_DIR}/scalable"
    cp -r "${SRC_DIR}"/src/scalable/places${folderstyle}                         "${THEME_DIR}/scalable/places"
    cp -r "${SRC_DIR}"/links/{16,22,24,32,scalable,symbolic}                     "${THEME_DIR}"

    if [ -n "${colorprefix}"  ]; then
      install -m644 "${SRC_DIR}"/src/colors${folderstyle}/color${colorprefix}/*.svg   "${THEME_DIR}/scalable/places"
    fi
  else
    local -r STD_THEME_DIR="${THEME_DIR%-dark}"

    install -d "${THEME_DIR}"/{16,22,24,symbolic}

    cp -r "${SRC_DIR}"/src/16/{actions,devices,places}                           "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/src/22/{actions,devices,places}                           "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/src/24/{actions,devices,places}                           "${THEME_DIR}/24"
    cp -r "${SRC_DIR}"/src/symbolic/*                                            "${THEME_DIR}/symbolic"

    # Change icon color for dark theme
    sed -i "s/#565656/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/actions/*
    sed -i "s/#727272/#aaaaaa/g" "${THEME_DIR}"/{16,22,24}/{places,devices}/*
    sed -i "s/#555555/#aaaaaa/g" "${THEME_DIR}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg

    cp -r "${SRC_DIR}"/links/16/{actions,devices,places}                         "${THEME_DIR}/16"
    cp -r "${SRC_DIR}"/links/22/{actions,devices,places}                         "${THEME_DIR}/22"
    cp -r "${SRC_DIR}"/links/24/{actions,devices,places}                         "${THEME_DIR}/24"
    cp -r "${SRC_DIR}"/links/symbolic/*                                          "${THEME_DIR}/symbolic"

    # Link the common icons
    ln -sr "${STD_THEME_DIR}/scalable"                                           "${THEME_DIR}/scalable"
    ln -sr "${STD_THEME_DIR}/32"                                                 "${THEME_DIR}/32"
    ln -sr "${STD_THEME_DIR}/16/apps"                                            "${THEME_DIR}/16/apps"
    ln -sr "${STD_THEME_DIR}/16/mimetypes"                                       "${THEME_DIR}/16/mimetypes"
    ln -sr "${STD_THEME_DIR}/16/panel"                                           "${THEME_DIR}/16/panel"
    ln -sr "${STD_THEME_DIR}/16/status"                                          "${THEME_DIR}/16/status"
    ln -sr "${STD_THEME_DIR}/22/emblems"                                         "${THEME_DIR}/22/emblems"
    ln -sr "${STD_THEME_DIR}/22/mimetypes"                                       "${THEME_DIR}/22/mimetypes"
    ln -sr "${STD_THEME_DIR}/22/panel"                                           "${THEME_DIR}/22/panel"
    ln -sr "${STD_THEME_DIR}/24/animations"                                      "${THEME_DIR}/24/animations"
    ln -sr "${STD_THEME_DIR}/24/panel"                                           "${THEME_DIR}/24/panel"
  fi

  # Replace file manager icon with icon of appropriate color (default icon being blue)
  if [ -n "${colorprefix}"  ]; then
    cp -r "${SRC_DIR}"/src/colors-circle/color"${colorprefix}"/default-folder.svg   "${THEME_DIR}/scalable/apps/file-manager.svg"
  fi

  if [ -n "${colorprefix}" ]; then
    install -m644 "${SRC_DIR}"/src/colors-16/color${colorprefix}/*.svg           "${THEME_DIR}/16/places"
  fi

  ln -sr "${THEME_DIR}/16"                                                       "${THEME_DIR}/16@2x"
  ln -sr "${THEME_DIR}/22"                                                       "${THEME_DIR}/22@2x"
  ln -sr "${THEME_DIR}/24"                                                       "${THEME_DIR}/24@2x"
  ln -sr "${THEME_DIR}/32"                                                       "${THEME_DIR}/32@2x"
  ln -sr "${THEME_DIR}/scalable"                                                 "${THEME_DIR}/scalable@2x"

  gtk-update-icon-cache "${THEME_DIR}"
}

while [ $# -gt 0 ]; do
  if [[ "$1" = "-a" ]]; then
    colors=("${COLOR_VARIANTS[@]}")
  elif [[ "$1" = "-c" ]]; then
    circle="true"
    echo -e "Install circular folder version! ..."
  elif [[ "$1" = "-d" ]]; then
    DEST_DIR="$2"
    shift
  elif [[ "$1" = "-n" ]]; then
    NAME="$2"
    shift
  elif [[ "$1" = "-h" ]]; then
    usage
    exit 0
  # If the argument is a color variant, append it to the colors to be installed
  elif [[ " ${COLOR_VARIANTS[*]} " = *" $1 "* ]] && \
       [[ "${colors[*]}" != *$1* ]]; then
    colors+=("$1")
  else
    echo "ERROR: Unrecognized installation option '$1'."
    echo "Try '$0 -h' for more information."
    exit 1
  fi

  shift
done

# Default name is 'Tela-circle'
: "${NAME:=Tela-circle}"

# By default, only the standard color variant is selected
for color in "${colors[@]:-standard}"; do
  for bright in "${BRIGHT_VARIANTS[@]}"; do
    install_theme "${color}" "${bright}"
  done
done
