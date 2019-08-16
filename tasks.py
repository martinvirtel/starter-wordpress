from invoke import task, run
import os
import dotenv
from functools import lru_cache

dotenv.load_dotenv()


HERE = os.path.split(__file__)[0]
PWD  = os.environ.get("PWD")

@lru_cache(2)
def wordpress():
    result = {
            'service' : run(""" docker stack ps $WORDPRESS_STACK_NAME --filter  \
                        "name=${WORDPRESS_STACK_NAME}_wordpress" --filter "desired-state=Running" \
                        --format '{{.ID}}' 2>/dev/null || echo ''""").stdout[:-1]
    }
    result["container"] = run(""" docker inspect %s \
                          --format '{{.Status.ContainerStatus.ContainerID}}' \
                          2>/dev/null || echo '' """ % result["service"]).stdout[:-1]
    return result


@task
def generate_certificates(c,force=False):
    """
      generates ssl certificates in certs/ if there are none

    """
    c.run(f"""

         export SSL_CERT=certs/$WORDPRESS_CNAME.cert.pem
         export SSL_KEY=certs/$WORDPRESS_CNAME.key.pem
         if [[ ! -f $SSL_KEY || ! -f $SSL_CERT ]] ; then
	   openssl req -x509 -newkey rsa:4096 -nodes -subj "/CN=$WORDPRESS_CNAME" \
	   	       -keyout $SSL_KEY -out $SSL_CERT -days 3650
         fi
    """)


@task(pre=(generate_certificates, ))
def deploy(c, stack="task-wordpress-with-self-signed-ssl.yml", remove=False):
    """
        deploy docker stack.
        --stack= points to the yml compose file
        parameters defined in .env:
        WORDPRESS_STACK_NAME
        WORDPRESS_MYSQL_ROOT_PASSWORD
        WORDPRESS_PORT
        WORDPRESS_SSH_PORT
        WORDPRESS_CNAME
    """
    if remove:
        c.run(f""" docker stack rm $WORDPRESS_STACK_NAME """)
    else:
        c.run(f"""

            cd {HERE}

            docker stack deploy --compose-file {stack} $WORDPRESS_STACK_NAME

            inv wp 'option set home https://'$WORDPRESS_CNAME
            inv wp 'option set siteurl https://'$WORDPRESS_CNAME
        """)


@task
def wp(c,run):
    """
        Usage: wp '
        execute wp-cli in service
    """
    c.run(f"""
	echo "wp {run}" >&2
	docker run -u 33 --rm --volumes-from {wordpress()["container"]} \
                   --network container:{wordpress()["container"]} wordpress:cli-php7.1 {run}
    """)
