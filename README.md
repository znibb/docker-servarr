# docker-servarr
Torrent management stack based on the *arr suite

## Server setup
1. Run init.sh: `./init.sh` (only required at first setup, initializes some files)
1. Input personal data into `.env` (can use `cat /etc/timezone` and `id` for timezone and UID information respectively)
1. Make sure that Docker network `traefik` exists: `docker network ls`
1. Run `docker compose up` and check logs

## Application setup
### Prowlarr
1. Log into prowlarr (Set up user//pass if first time logging in)
1. Settings->Indexers, add FlareSolverr
    1. Tags: flaresolverr
    1. Host: http://flaresolverr:8191
1. Indexers->Add Indexer, select your indexers of choice but make sure to add `flaresolverr` tag to them

### Sonarr
1. Log into Sonarr (Set up user//pass if first time logging in)
1. Settings->General, copy API Key
1. Back to Prowlarr
1. Settings->Apps, Add Application->Sonarr
    - Prowlarr Server: http://prowlarr:9696
    - Sonarr Server: http://sonarr:8989
    - API Key: As generated in Sonarr

### Radarr
1. Log into Radarr (Set up user//pass if first time logging in)
1. Settings->General, copy API Key
1. Back to Prowlarr
1. Settings->Apps, Add Application->Sonarr
    - Prowlarr Server: http://prowlarr:9696
    - Sonarr Server: http://radarr:7878
    - API Key: As generated in Radarr

### Readarr
1. Open Readarr
1. Settings->General
    - Authentication: Basic (Browser Popup)
    - Username//Password, set according to personal preference
    - API Key, copy
1. Back to Prowlarr
1. Settings->Apps, Add Application->Readarr
    - Prowlarr Server: http://prowlarr:9696
    - Sonarr Server: http://readarr:8787
    - API Key: As generated in Readarr

### Bazarr
1. Open Bazarr
1. Settings->General
    - Authentication: Basic
    - Username//Password, set according to personal preference
    - API Key, copy
1. Settings->Sonarr
    1. Enabled: On
    1. Address: sonarr
    1. API Key: Get from Sonarr Settings->General
    1. Click Test, should reply with version
    1. SAVE
1. Settings->Radarr
    1. Enabled: On
    1. Address: radarr
    1. API Key: Get from Radarr Settings->General
    1. Click Test, should reply with version
    1. SAVE
1. Settings->Languages, follow [guide](https://trash-guides.info/Bazarr/Setup-Guide/#languages)
1. Settings->Providers, add choice providers

### Transmission
1. Open Transmission (user//pass as set in .env and transmission_password.secret)
1. Hamburger menu->Edit preferences->Network, check that Peer listening port shows "Port is Open"
1. Back to Prowlarr
1. Settings->Download Clients, Add Download Client->Transmission
    1. Host: transmission
    1. Username//Password, same as used to log into web UI above