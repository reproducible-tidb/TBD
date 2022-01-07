# checkout code
cd /src/$pkgname/git
git checkout $pkgcommit

# build and package
export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)
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
sha256sum $tarball

