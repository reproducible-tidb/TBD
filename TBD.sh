#!/bin/bash
source $1
docker run -it -v $(realpath $1):/src/pkgmeta -v $(dirname "$(realpath "${BASH_SOURCE[0]}")")/tTBD.sh:/usr/bin/tTBD.sh -v $PWD:/publish $image "bash" "-c" "source /src/pkgmeta && source /usr/bin/tTBD.sh"
