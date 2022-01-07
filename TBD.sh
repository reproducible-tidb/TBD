#!/bin/bash
source $1

CRI="${TBD_CRI:-docker}"

$CRI run -it \
    -v $(realpath $1):/src/pkgmeta \
    -v $(dirname "$(realpath "${BASH_SOURCE[0]}")")/iTBD.sh:/usr/bin/iTBD.sh \
    -v $PWD:/publish \
    $image \
    "bash" "-c" "source /src/pkgmeta && source /usr/bin/iTBD.sh"

