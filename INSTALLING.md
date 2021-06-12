
## How To: Install on AWS Linux2

sudo yum update -y
sudo yum install docker tmux -y
git clone https://github.com/martinvirtel/starter-wordpress.git ./wordpress
cd ./wordpress
- fill versicherungsmonitor profile in /root/,aws/credentials 
- create .credentials from .credentials-example
- create .env from .env-example
- create certbot/cloudflare.ini from certbot/cloudflare.ini-example
- install restore-on-start.service-example in /etc/systemd/system
- run systemctl endable restore-on-start; systemctl daemon-reload

Docker-Compose:

- build tools
sudo yum groupinstall "Development Tools"


- Python 3
sudo yum install python3-devel


Dann: pip3 install -IU docker-compose

