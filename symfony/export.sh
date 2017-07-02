#!/usr/bin/env bash
source ./variables.sh
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ARTEFACT_DIR=${ARTEFACT_DIR:-artefact}
PACKAGE_NAME="${ARTEFACT_DIR}/package"
BILD_DIR_NAME=${BILD_DIR_NAME:-../dziura-backend-php}

excludeImages=('ansible')

rm -rf "$PROJECT_DIR/$ARTEFACT_DIR"
mkdir -p "$PROJECT_DIR/$PACKAGE_NAME"


function parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

function reload {
    source ${BASH_SOURCE[0]}
}
alias r=reload

function getImageField {
    local imageId=$1
    local field=$2
    : ${imageId:? reuired}
    : ${field:? required}

    docker images --no-trunc |sed -n "/${imageId}/ s/ \+/ /gp"|cut -d" " -f $field
}

function getImageName() {
    getImageField $1 1
}

function getImageTag() {
    getImageField $1 2
}

function substr {
    local length=${3}

    if [ -z "${length}" ]; then
        length=$((${#1} - ${2}))
    fi

    local str=${1:${2}:${length}}

    if [ "${#str}" -eq "${#1}" ]; then
        echo "${1}"
    else
        echo "${str}"
    fi
}

function strpos {
    local str=${1}
    local offset=${2}

    if [ -n "${offset}" ]; then
        str=`substr "${str}" ${offset}`
    else
        offset=0
    fi

    str=${str/${2}*/}

    if [ "${#str}" -eq "${#1}" ]; then
        return 0
    fi
    return 1

}

function saveDockerInfo {
    eval $(parse_yaml "${PROJECT_DIR}/dockerinfo.yml" "")
}

function saveAllImage() {
    local ids=$(docker images | grep $envVars_APP_NAME | grep $envVars_APP_VERSION  | awk '{print $3}')
    local name safename tag


    for id in $ids; do
        name=$(getImageName $id)
        tag=$(getImageTag $id)

        exportImage=0
        for i in "${!excludeImages[@]}"
        do
            strpos "${tag}" "${excludeImages[$i]}"
            if [ $? -eq 1 ]; then
                exportImage=1
            fi
        done

        if [ $exportImage -eq 0 ]; then
            if [[  $name =~ / ]] ; then
               dir=$PROJECT_DIR/$PACKAGE_NAME/${name%/*}
               mkdir -p $dir
            fi
            echo [DEBUG] save $name:$tag ...
            (time  docker save -o $PROJECT_DIR/$PACKAGE_NAME/$name.$tag.dim $name:$tag) 2>&1|grep real
        fi
    done
}

cp "${PROJECT_DIR}/build.tar" "${PROJECT_DIR}/${PACKAGE_NAME}/"
saveDockerInfo
saveAllImage
tar -C "${PROJECT_DIR}/${ARTEFACT_DIR}" -cvf "${PROJECT_DIR}/${PACKAGE_NAME}.tar" package
rm -rf $PROJECT_DIR/$PACKAGE_NAME