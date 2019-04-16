# rancheros-docker-media

## What is this?
This is inteded as a complete step by guide step for FreeNAS users to set up different software with dockers on their FreeNAS system.  
Since FreeNAS does not have docker native, it needs to be done inside a VM, and RancherOS is used for that. The hard part with this setup is getting networking, permissions and shares to work.  
This guide is including how to get access to the files on Windows as well, but if you just use Linux, the steps with SMB can probably be skipped.  
Why docker over jails? Portability to another system, the amount of premade docker "recepies" is huge.  
Take a look at the dockers from linuxserver.io for more applications https://hub.docker.com/r/linuxserver



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


### Variables for my system/hardware
IP to FreeNAS: 10.0.0.113  
Freenas version: 11.2-U3  
Gateway to my router: 10.0.0.138  
DNS1: 8.8.8.8  
DNS2: 4.2.2.2  
Network interface in FreeNAS: re1  
FreeNAS volume1: tank  
FreeNAS volume2: ssd (TODO)  

#### Variables that can be changed
Name of user/group in FreeNAS: rancher  
User/Group ID: 1020  
Dataset name: rancher  



# Step by step guide:

# In FreeNAS GUI
## Create user/group
This creates the user and group to be used for the dataset and share
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

## Create dataset
- Storage
- Create dataset
- Dataset Name: rancher
- Add dataset
- Change permissions
- Owner (user): rancher
- Owner (group): rancher
- Set permission recursivley: check

## Start services:
- Services
- Enable and start NFS, SMB and SSH and check "Start on boot"

## Shares
This step creates the share as both Linux and Windows share.  
The important part about this is creating the unix share with the root / wheel user and group. There should be a better way to set this up, but at least it works this way.
- Sharing
- Unix
- Add unix share
- Path: /mnt/tank/rancher
- Maproot User: root
- Maproot Group: wheel
- OK
- Windows share
- Add windows share
- Path: /mnt/tank/rancher
- Name: rancher
- Apply Default Permissions: uncheck


## Setup RancherOS
This steps creates a VM with the OS "RancherOS", called "Docker Host" in FreeNAS
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
## Configure the network
This changes the default IP assigned to the VM and makes sure it uses correct network settings.  
In shell on local computer (Linux subsystem for Windows 10, (Ubuntu) to get SSH with more functionality on Windows)
- `ssh rancher@10.0.0.XXX`
- `ifconfig` (to check network interfaces, should be eth0 as main interface)
- `sudo ros config get rancher.network`
- `sudo ros config set rancher.network.interfaces.eth0.address 10.0.0.200/24`
- `sudo ros config set rancher.network.interfaces.eth0.gateway 10.0.0.138`
- `sudo ros config set rancher.network.interfaces.eth0.mtu 1500`
- `sudo ros config set rancher.network.interfaces.eth0.dhcp false`
- `sudo ros config set rancher.network.nameservers "['8.8.8.8','4.2.2.2','10.0.0.138']"`
- `sudo ros config get rancher.network`
- `sudo reboot`


## Mount NFS share inside RancherOS VM
This step creates a docker
- `ssh rancher@10.0.0.200`
- rancher_password
- `sudo su -`
- `cd /var/lib/rancher/conf/cloud-config.d/`
- `wget https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/rancheros-cloud-config.yml`
- `vi rancheros-cloud-config.yml`
- edit SERVER and SHARE (i for insert, esc for exit out of insert, :wq for quit with save)
- `sudo reboot`
- check that nfs share is there, ssh in again and:
- `sudu su`
- `cd /mnt/nfs-1/`


## Create media folders with the 1020 user
This is an important part to get permissions to work across dockers and windows share.  
Check out the video in Credits (Part 2) for more details.  
Creates the 1020 user inside the RancherOS and creates the folders for the share. This makes sure the 1020 user owns the folders.
- `ssh rancher@10.0.0.200`
- rancher_password
- `sudo su -`
- `adduser -u 1020 share_user`
- share_user_password
- `su share_user`
- `cd /mnt/nfs-1/`
- `mkdir Downloads`
- `mkdir TV`
- `mkdir Movies`


## Add dockers
First get root permissions, then navigate to the cloud-config-d folder. All files added to that folder is loaded on boot.  
The .yml files contains recepies/configuration for the docker containers. Just get the files of the dockers you want, and reboot to install them.  
**(Protip: copy the files to your own github and modify TZ to your own timezone)**

`sudo su -`  
`cd /var/lib/rancher/conf/cloud-config.d/`

### Portainer
- `wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/portainer.yml

### Media
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/plex.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/radarr.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/sonarr.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/transmission.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/jackett.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/ombi.yml

### Managment
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/tautulli.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/heimdall.yml

### Files / backup (not completed)
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/nextcloud.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/nginx.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/mariadb.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/letsencrypt.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/resilio-sync.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/duplicati.yml
`wget` https://raw.githubusercontent.com/redshift-s/rancheros-docker-media/master/lychee.yml

`sudo reboot`


## Access dockers:
Portainer:
http://10.0.0.200:9000

Heimdall:
http://10.0.0.200:5555

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
**Q:** How does this make the nfs share available inside the VM?  
**A:** The file rancheros-cloud-config.yml creates a docker that makes your share available  

**Q:** Can I use my existing media folders and modify it to be used like in this guide?  
**A:** Needs to be tested, important parts are users: root, wheel and 1020. And to create the media(TV, Movies etc) folders with the 1020 user.



### Notes
- https://old.reddit.com/r/usenet/wiki/docker

