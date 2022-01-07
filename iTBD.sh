# util funcs
## check if a function exists
fn_exists() { declare -F "$1" > /dev/null; }

# checkout code
cd /src/$pkgname/git
git checkout $pkgref

# build and package
export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)
fn_exists prepare && prepare
build

export pkgdir=`mktemp -d`
package

cd $pkgdir
tarball=/publish/$pkgname-$pkgver-$pkgrel.tar
tar \
    --sort=name \
    --mtime="@${SOURCE_DATE_EPOCH}" \
    --owner=0 --group=0 --numeric-owner \
    --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
    -cf $tarball *

find $pkgdir -type f -exec sha256sum {} \;
sha256sum $tarball

