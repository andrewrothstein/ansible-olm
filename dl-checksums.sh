#!/usr/bin/env sh
set -e
DIR=~/Downloads
MIRROR=https://github.com/operator-framework/operator-lifecycle-manager/releases/download

dl() {
    local app=$1
    local ver=$2
    local lchecksums=$3
    local os=$4
    local arch=$5
    local archive_type=${6:-tar.gz}
    local platform="${os}_${arch}"
    local file="${app}_${ver}_${platform}.${archive_type}"
    local url="$MIRROR/v$ver/$file"
    printf "    # %s\n" $url
    printf "    %s: sha256:%s\n" $platform $(grep $file $lchecksums | awk '{print $1}')
}

dl_ver() {
    local app=$1
    local ver=$2
    # https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.21.2/checksums.txt
    local url="$MIRROR/v$ver/checksums.txt"
    local lchecksums="$DIR/${app}_${ver}_checksums.txt"
    if [ ! -e $lchecksums ];
    then
        curl -sSLf -o $lchecksums $url
    fi

    printf "  # %s\n" $url
    printf "  '%s':\n" $ver

    dl $app $ver $lchecksums linux amd64
    dl $app $ver $lchecksums linux arm64
    dl $app $ver $lchecksums linux ppc64le
    dl $app $ver $lchecksums linux s390x
}

dl_ver operator-lifecycle-manager 0.23.0
dl_ver operator-lifecycle-manager 0.24.0
dl_ver operator-lifecycle-manager ${1:-0.25.0}
