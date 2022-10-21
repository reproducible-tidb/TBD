# util funcs
## check if a function exists
fn_exists() { declare -F "$1" > /dev/null; }
prepare || true

# checkout code
if [ ! -z "$BUILD_DIR" ]; then
  cd $BUILD_DIR
else
  cd /src/tbdcache/$pkgname
fi

# build and package
if [ -d .git ]; then
  git checkout $pkgref
  export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)
else
  export SOURCE_DATE_EPOCH=$(date "+%s")
fi
build

export pkgdir=`mktemp -d`
package

cd $pkgdir

if [ ! -z "$PKG_DIR" ]; then
  export outputdir=$PKG_DIR
else
  export outputdir=/publish
fi

tarball=$outputdir/$pkgname-$pkgver-$pkgrel.tar.gz
gtar \
    --sort=name \
    --mtime="@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
    -zcf $tarball *

find $pkgdir -type f -exec sha256sum {} \;
tarsha256=`sha256sum $tarball | cut -d ' ' -f1`
echo "{\"version\":\"$pkgver\",\"sha256\":\"$tarsha256\",\"timestamp\":\""`date +%s`"\"}" > ${tarball}.json
echo "build result:\n"
echo "{\"package\":\"$pkgname\",\"version\":\"$pkgver\",\"entrypoint\":\"$entrypoint\",\"description\":\"$pkgdesc\",\"file\":\"$tarball\"}"
