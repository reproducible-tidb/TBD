#!/bin/bash
set -e
source $1

# update git cache
cachedir=${TBD_CACHE:-$(realpath $(dirname $1))/.cache}
mkdir -p $cachedir
if [ -d $cachedir/$pkgname ]; then
  opwd=$PWD
  cd $cachedir/$pkgname
  git reset --hard HEAD
  git fetch --all
  cd $opwd
else
  git clone $pkggit $cachedir/$pkgname
fi

CRI="${TBD_CRI:-docker}"
withTTY=""
if [ "$(tty)" != "not a tty" ]; then
  withTTY="-it"
fi

$CRI run $withTTY \
    -v $(realpath $1):/src/pkgmeta \
    -v $cachedir:/src/tbdcache \
    -v $(dirname "$(realpath "${BASH_SOURCE[0]}")")/iTBD.sh:/usr/bin/iTBD.sh \
    -v $PWD:/publish \
    $image \
    "bash" "-c" "source /src/pkgmeta && source /usr/bin/iTBD.sh"

