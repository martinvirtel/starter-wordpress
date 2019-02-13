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



for A in \
	advanced-gutenberg \
	adminimize \
	duplicate-post \
	genie-wp-favicon \
	ghostkit \
	gutenberg \
	h5p \
	header-footer-code-manager \
	show-modified-date-in-admin-lists \
	simple-custom-post-order \
	simply-static \
	smart-slider-3 \
	under-construction-page \
	wp-ses \
; do 

	make cli CLI="plugin install --activate $A"

done

make cli CLI='rewrite structure "/%year%/%monthnum%/%postname%"'


