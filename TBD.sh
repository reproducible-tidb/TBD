#!/bin/bash
set -e
source $1

# update git cache
cachedir=$(realpath $(dirname $1))/.cache/$pkgname
mkdir -p $cachedir
if [ -d $cachedir/git ]; then
  opwd=$PWD
  cd $cachedir/git
  git fetch --all
  git pull
  cd $opwd
else
  git clone $pkggit $cachedir/git
fi

CRI="${TBD_CRI:-docker}"

$CRI run -it \
    -v $(realpath $1):/src/pkgmeta \
    -v $cachedir:/src/$pkgname \
    -v $(dirname "$(realpath "${BASH_SOURCE[0]}")")/iTBD.sh:/usr/bin/iTBD.sh \
    -v $PWD:/publish \
    $image \
    "bash" "-c" "source /src/pkgmeta && source /usr/bin/iTBD.sh"

