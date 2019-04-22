### Just notes below, readme.md for guide



ssh rancher@10.0.0.200

# Show all dockers
docker ps -a

# Remove configuration to reset dockers (ombi example)
cd /mnt/nfs-1/config/
ls -l #see all folders
rm -r ombi 

sudo su -
cd /var/lib/rancher/conf/cloud-config.d/

wget https://raw.githubusercontent.com/walkerk1980/docker-nfs-client/master/rancheros-cloud-config.yml
vi rancheros-cloud-config.yml

i #insert mode
SERVER: 10.0.0.113
SHARE /mnt/tank/rancher
esc #view mode
:wq #close with save
:q #close and save


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
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/nextcloud/letsencrypt.yml

sudo system-docker run -d --net=host --name busydash husseingalal/busydash


wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/nextcloud-linuxserver/letsencrypt.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/nextcloud-linuxserver/mariadb.yml
wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/nextcloud-linuxserver/nextcloud.yml


#Reset nextcloud password
https://docs.nextcloud.com/server/15/admin_manual/configuration_user/reset_admin_password.html




#Create Telegram channel with bot
Create private channel
Msg @BotFather
/newbot
name_of_bot
note down the token
invite the bot to your channel

# Get Telegram chat_id
The easiest way is to invite @get_id_bot in your chat and then type inside your chat:
/my_id@get_id_bot



NOTES:

The reason hardlinks aren't working is because you are using fragmented volume mappings
What you want is this:
Transmission docker volume mapping:
      - /mnt/nfs-1/Downloads:/data/Downloads
Radarr volume mappings:
      - /mnt/nfs-1:/data
Radarr has to have a unified file system to be able to create hardlinks
In your current configuration, radarr is using /data/movies and /data/downloads, but it will now use /data/Movies and /data/Downloads.
 You should also change Transmission settings from using /data/downloads to /data/Downloads