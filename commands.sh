### Just notes below, readme.md for guide
ssh rancher@10.0.0.200

sudo ros config get rancher.network
sudo ros config set rancher.network.interfaces.eth0.address 10.0.0.200/24
sudo ros config set rancher.network.interfaces.eth0.gateway 10.0.0.138
sudo ros config set rancher.network.interfaces.eth0.mtu 1500
sudo ros config set rancher.network.interfaces.eth0.dhcp false
sudo ros config set rancher.network.nameservers "['8.8.8.8','4.2.2.2','10.0.0.138']"

ifconfig
docker ps
sudo reboot

sudo su -
cd /var/lib/rancher/conf/cloud-config.d/
ls
wget https://raw.githubusercontent.com/walkerk1980/docker-nfs-client/master/rancheros-cloud-config.yml
vi rancheros-cloud-config.yml
i #insert mode
SERVER: 10.0.0.113
SHARE /mnt/tank/rancher
esc #view mode
:wq #close with save
:q #close and save

sudo reboot

cd /mnt/nsf-1
ls


docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/nfs-1/portainer:/data --restart always --name portainer portainer/portainer

10.0.0.200:9000

wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/radarr.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/sonarr.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/transmission.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/portainer.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/plex.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/jackett.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/tautulli.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/nextcloud.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/ombi.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/nginx.yml

sudo system-docker run -d --net=host --name busydash husseingalal/busydash

