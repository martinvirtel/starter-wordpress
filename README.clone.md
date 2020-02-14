# How To: Clone this site

## 1. copy files + db 
 
```
export SOURCEDIR=...
export DESTDIR=...
cd $SOURCEDIR
make backup-db
tar cpzf - . | (cd $DESTDIR; tar xvzpf -)
cp sql/dump.sql $DESTDIR/sql/restore.sql
cd $DESTDIR
```

## 2. set port and name in config.makefile
cd $DESTDIR
vim config.makefile

```
STACK_NAME := xxi

WORDPRESS_PORT	    := 8091
WORDPRESS_CNAME     := xxi.la22.org
WORDPRESS_NAME      := xxi.la22.org
```

## 3. deploy and test

```
cd $DESTDIR
make deploy
make restore-db
make set-cname 
make enable-site.conf
sudo service nginx restart
```

## 5. connect to nginx and test

## 6. certbot

	choose "redirect"

## 7. enable ssl

```
make set-cname-ssl
make enable-site-ssl.conf
```

