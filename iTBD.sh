# util funcs
## check if a function exists
fn_exists() { declare -F "$1" > /dev/null; }
prepare || true

# checkout code
if [ -z "$BUILD_DIR" ]; then
  cd /src/tbdcache/$pkgname
else
  cd $BUILD_DIR
fi
git checkout $pkgref

# build and package
export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)
build

export pkgdir=`mktemp -d`
package

cd $pkgdir
tarball=/publish/$pkgname-$pkgver-$pkgrel.tar.gz
tar \
    --sort=name \
    --mtime="@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
    -zcf $tarball *

find $pkgdir -type f -exec sha256sum {} \;
tarsha256=`sha256sum $tarball | cut -d ' ' -f1`
echo "{\"version\":\"$pkgver\",\"sha256\":\"$tarsha256\",\"timestamp\":\""`date +%s`"\"}" > ${tarball}.json
