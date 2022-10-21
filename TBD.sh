#!/bin/bash
set -e
source $1

# update git cache
cachedir=${TBD_CACHE:-$(realpath $(dirname $1))/.cache}
mkdir -p $cachedir
opwd=$PWD
if [ ! -z "$pkggit" ]; then
  if [ -d $cachedir/$pkgname ]; then
    cd $cachedir/$pkgname
    git reset --hard HEAD
    git fetch --all
    cd $opwd
  else
    git clone $pkggit $cachedir/$pkgname
  fi
elif [ ! -z "$pkgurl" ]; then
  wget $pkgurl -O /tmp/$pkgname.tbd-downloaded
  
  mkdir -p $cachedir/$pkgname
  cd $cachedir/$pkgname
  tar xvf /tmp/$pkgname.tbd-downloaded
  cd $opwd
else
  echo "Either pkggit or pkgurl must be set in the .TBD file."
  exit 127
fi

CRI="${TBD_CRI:-docker}"
withTTY=""
if [ "$(tty)" != "not a tty" ]; then
  withTTY="-it"
fi

if [ $CRI == "none" ]; then
  pwd=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
  export BUILD_DIR=$cachedir/$pkgname
  source $1
  source $pwd/iTBD.sh
else
  $CRI run $withTTY \
      -v $(realpath $1):/src/pkgmeta \
      -v $cachedir:/src/tbdcache \
      -v $(dirname "$(realpath "${BASH_SOURCE[0]}")")/iTBD.sh:/usr/bin/iTBD.sh \
      -v $PWD:/publish \
      $image \
      "sh" "-c" "source /src/pkgmeta && source /usr/bin/iTBD.sh"
fi
