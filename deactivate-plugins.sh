#! /bin/bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# -o pipefail fail immediately if error in pipe
# -e fail immediately on error
# -E subshells inherit ERR handler
# -u Error on unset variables
# -x Echo all lines to STDERR
# -k get assignments 

set -Eeuo pipefail

if [ "${DEBUG:-}" != "" ] ; then
    set -x
fi



for A in $(make cli CLI="plugin list" | awk '/active/ { print $1 }')
  do 

	make cli CLI="plugin deactivate $A"

done



