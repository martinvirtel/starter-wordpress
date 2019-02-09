
- backup / restore (Ideas: https://hub.docker.com/r/aveltens/wordpress-backup/)

- make wpses_options from_name = blogname
  this did not work:
  994  make cli CLI="wp option patch update wpses_options from_name mper20.la22.org"


DONE

- certbot through nginx works, but changing siteurl and home vars to https:// url leads 
to endless redirect on curl -v 2>&1 https://mper20.dyndns.info/wp-login.php

- wordpress instance can't send e-Mails
