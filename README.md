# rancheros-docker-media

## TODO
- [X] Setup RancherOS on FreeNAS
- [X] Setup Networking so dockers can be accessed on local network
- [X] Setup shares(NFS) that works with permissions inside dockers and accessible in windows as Windows Share
- [X] Setup Portainer
- [X] Setup Radarr
- [X] Setup Ombi
- [X] Setup Plex
- [X] Setup Transmission
- [X] Verify setup of portainer from .yml file insted of command
- [ ] Get hardlinks in Radarr to work
- [ ] Complete setup of Sonarr
- [ ] Test and create step by step for updating containers
- [ ] Setup folder structure better??
- [ ] Modify so all config and VM raw file is stored on a different FreeNAS volume (ssd)
- [ ] Get NextCloud working with nginx/letsencrypt
- [ ] Configuration to get access to dockers outside network (VPN?)
- [ ] Setup resilio-sync
- [ ] Setup duplicati
- [ ] Setup lychee or piwigo


## Credits
- Keith Walker's videos on how to get permissions and networking to work (Part 1 and 2):
  + https://www.youtube.com/channel/UCRf6gQ4eg6QE_8UhTrghpPQ


### My variables:
IP to FreeNAS: 10.0.0.113

Gateway to my router: 10.0.0.138

DNS1: 8.8.8.8

DNS2: 4.2.2.2

FreeNAS volume1: tank

FreeNAS volume2: ssd (TODO)



# Step by step guide:

# In FreeNAS GUI
## Create user and dataset
- Account
- Group
- Add group
- Group ID: 1020
- Group Name: rancher
- User
- Add user
- User ID: 1020
- Username: rancher
- Create new primary group: uncheck
- Primary Group: rancher
- Shell: bash
- Full Name: rancher user
- E-mail: rancher@freenas.local
- Password: rancher_user_password x2
- Storage
- Create dataset
- Dataset Name: rancher
- Add dataset
- Change permissions
- Owner (user): rancher
- Owner (group): rancher
- Set permission recursivley: check

## Start NFS and SMB:
- Services
- Enable and start NFS and SMB and check "Start on boot"

## Shares
- Sharing
- Unix
- Add unix share
- Path: /mnt/tank/rancher
- Maproot User: root
- Maproot Group: wheel
- OK
- Windows share
- Add windows share:
- Path: /mnt/tank/rancher
- Name: rancher
- Apply Default Permissions: uncheck


## Setup RancherOS
- Virtual Machines 
- Add
- Dropdown: Docker Host
- Name: rancherVM
- Virtual CPUs: 2
- Memory: 4096
- Network: Select network on FreeNAS (re1)
- Raw filename: rancheros
- Raw filename password: rancher_password
- Raw file location: /mnt/tank/vm/
- DONE


## Login to find IP of rancherOS VM:
- Press ... on the virtual machine and select Serial
- Check IP of rancher machine, starts with same as local network 10.0.0.XXX

<details>
    <summary>Picture</summary>
    <img src="https://user-images.githubusercontent.com/49619612/56118316-4cbae680-5f6a-11e9-800f-f4ebb9d7d325.PNG">
</details>



# In RancherOS (SSH)
In shell on local computer (Linux subsystem for Windows 10, (Ubuntu) to get SSH with more functionality on Windows)
- ssh rancher@10.0.0.XXX
- ifconfig (check network interfaces)
- sudo ros config get rancher.network
- sudo ros config set rancher.network.interfaces.eth0.address 10.0.0.200/24
- sudo ros config set rancher.network.interfaces.eth0.gateway 10.0.0.138
- sudo ros config set rancher.network.interfaces.eth0.mtu 1500
- sudo ros config set rancher.network.interfaces.eth0.dhcp false
- sudo ros config set rancher.network.nameservers "['8.8.8.8','4.2.2.2','10.0.0.138']"
- sudo ros config get rancher.network
- sudo reboot


## create media folders with 1020 user
- ssh rancher@10.0.0.200
- rancher_password
- sudo su -
- adduser -u 1020 share_user
- enter password
- su share_user
- cd /mnt/nfs-1/
- mkdir Downloads
- mkdir TV
- mkdir Movies


## Mount NFS share inside RancherOS VM
- ssh rancher@10.0.0.200
- rancher_password
- sudo su -
- cd /var/lib/rancher/conf/cloud-config.d/
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/rancheros-cloud-config.yml
- vi rancheros-cloud-config.yml
- edit SERVER and SHARE (i for insert, esc for exit out of insert, :wq for quit with save)
- sudo reboot
- check that nfs share is there, ssh in again and:
- sudu su
- cd /mnt/nfs-1/


## Add portainer docker 
- docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/nfs-1/config/portainer:/data --restart always --name portainer portainer/portainer

OR (this seems to work, but it's showing as "os" in portainer at the same level as other dockers)
- sudo su -
- cd /var/lib/rancher/conf/cloud-config.d/
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/portainer.yml


## Add more dockers (Protip: copy files to own github and modify TZ)
- sudo su -
- cd /var/lib/rancher/conf/cloud-config.d/
### Media
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/radarr.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/sonarr.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/transmission.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/plex.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/jackett.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/ombi.yml

### Managment
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/tautulli.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/heimdall.yml

### Files / backup
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/nextcloud.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/nginx.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/mariadb.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/letsencrypt.yml

- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/resilio-sync.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/duplicati.yml
- wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/lychee.yml

- sudo reboot


## Access dockers:
Portainer:
http://10.0.0.200:9000

Radarr:
http://10.0.0.200:7878

Sonarr:
http://10.0.0.200:8989

Jacket:
http://10.0.0.200:9117

Plex:
http://10.0.0.200:32400/web

Transmission:
http://10.0.0.200:9091/transmission/web/

Ombi:
http://10.0.0.200:3579

Tautulli:
http://10.0.0.200:8181


## My configurations of dockers
### Plex
- Login with Plex user
- Add Movies from /movies
- Add TV from /tv


### Radarr
- Add movies
- Bulk Import Movies
- Path: /data/movies/
- Select all - import
- Settings
- Profiles
- HD-1080p: uncheck HDTV-1080p and Remux-1080p
- HD-720p/1080p: uncheck HDTV-1080p, Remux-1080p, Remux-2160p, HDTV-720p
- Indexers
- "+"
- Add provider (Username / API Key / Passkey )
- Download Client
- "+"
- Transmission
- Name: Transmission
- Host: 10.0.0.200
- Connect
- "+"
- Telegram
- Name
- Bot Token: Get it from Telegram
- Chat ID: Get it from Telegram
- UI: Change time formats
- General
- Copy API Key


### Ombi
- Movies - Radarr
- Enabled: check
- Hostname or IP: 10.0.0.200
- Port: 7878
- API Key: Paste API key from Radarr
- Get QUality Profiles select HD-1080p
- Get Root Folders, select /data/movies/
- Submit
- Notofications - Telegram
- Enabled: check
- Bot API: Get it from Telegram
- Chat ID: Get it from Telegram
- Markdown Formatting
- Submit
- Media Server - Plex:
- Enable: check
- Add Server
- Server name: Rancher
- Hostname or IP: 10.0.0.200
- Port: 32400
- Submit


### Transmission
No configuration needed for now (maybe after VPN setup)


### Tautulli
- Settings
- Plex Media Server
- Plex IP Adress or Hostname: Select the server - Verify Server


### Heimdall
http://10.0.0.200:5555
Add all URL's listed above
Add Sonarr, Radarr and Tautulli with API Key




### NextCloud:
Modify this guide to work on RancherOS?
- https://blog.ssdnodes.com/blog/installing-nextcloud-docker/



# FAQ
How does this make the nfs share available inside the VM?



### Notes
- https://old.reddit.com/r/usenet/wiki/docker

