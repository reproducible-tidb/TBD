#!/bin/bash
set -e
source $1

realpath() (
  OURPWD=$PWD
  cd "$(dirname "$1")"
  LINK=$(readlink "$(basename "$1")")
  while [ "$LINK" ]; do
    cd "$(dirname "$LINK")"
    LINK=$(readlink "$(basename "$1")")
  done
  REALPATH="$PWD/$(basename "$1")"
  cd "$OURPWD"
  echo "$REALPATH"
)

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
elif [ "${#pkgurl[@]}" -gt 1 ]; then
  mkdir -p $cachedir/downloads/
  files=()
  for fileaddr in ${pkgurl[@]}; do
    if [[ "$fileaddr" =~ (.*)::(.*) ]]; then
      fname=${BASH_REMATCH[0]}
      url=${BASH_REMATCH[1]}
      wget "$url" -O $cachedir/downloads/$fname
      files+=("$cachedir/downloads/$fname")
    else
      wget $fileaddr -O $cachedir/downloads/$pkgname.tbd-downloaded
      files+=("$cachedir/downloads/$pkgname.tbd-downloaded")
    fi
  done

  mkdir -p $cachedir/$pkgname
  cd $cachedir/$pkgname
  for f in ${files[@]}; do
    tar xvf $f || cp $f .
  done
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
  export PKG_DIR=$cachedir/.pkg
  mkdir -p $PKG_DIR
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
