# docker-servarr <!-- omit from toc -->
Media management stack based on the *arr suite

## Table of Contents <!-- omit from toc -->
- [1. Server setup](#1-server-setup)
- [2. Application setup](#2-application-setup)
  - [2.1. Prowlarr](#21-prowlarr)
  - [2.2. Sonarr](#22-sonarr)
  - [2.3. Radarr](#23-radarr)
  - [2.4. Readarr](#24-readarr)
  - [2.5. Bazarr](#25-bazarr)
  - [2.6. Transmission](#26-transmission)


## 1. Server setup
1. Run init.sh: `./init.sh` (only required at first setup, initializes some files)
1. Input personal data into `.env` (can use `cat /etc/timezone` and `id` for timezone and UID information respectively)
1. Create a transmission password and put it in `./secrets/transmission_password.secret`
1. Make sure that Docker network `traefik` exists: `docker network ls`
1. Run `docker compose up` and check logs

## 2. Application setup
Services are set up to use Authentik for authentication, if that's not preferable simply comment out the middleware lables from each service

Recent versions **require** that you use authentication. If you don't care for authentication when accessing the services locally you can no longer skip authentication. You can however setup authentication initially and then enter the respective containers with `docker exec -it <service> bash` and open the config file with `vi /config/config.xml`. Change the `AuthenticationMethod` tag to `External` and restart the container.

### 2.1. Prowlarr
1. Log into prowlarr (Set up user//pass if first time logging in, use `Forms`)
1. Settings->Indexers, add FlareSolverr
    1. Tags: flaresolverr
    1. Host: http://flaresolverr:8191
1. Indexers->Add Indexer, select your indexers of choice but make sure to add `flaresolverr` tag to them

### 2.2. Sonarr
1. Log into Sonarr (Set up user//pass if first time logging in, use `Forms`)
1. Settings->General, copy API Key
1. Back to Prowlarr
1. Settings->Apps, Add Application->Sonarr
    - Prowlarr Server: http://prowlarr:9696
    - Sonarr Server: http://sonarr:8989
    - API Key: As generated in Sonarr

### 2.3. Radarr
1. Log into Radarr (Set up user//pass if first time logging in, use `Forms`)
1. Settings->General, copy API Key
1. Back to Prowlarr
1. Settings->Apps, Add Application->Sonarr
    - Prowlarr Server: http://prowlarr:9696
    - Sonarr Server: http://radarr:7878
    - API Key: As generated in Radarr

### 2.4. Readarr
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

### 2.5. Bazarr
1. Open Bazarr
1. Settings->General
    - Authentication: Basic
    - Username//Password, set according to personal preference
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

### 2.6. Transmission
1. Open Transmission (user//pass as set in .env and ./secrets/transmission_password.secret)
1. Hamburger menu->Edit preferences->Network, check that Peer listening port shows "Port is Open"
1. Back to Prowlarr
1. Settings->Download Clients, Add Download Client->Transmission
    1. Host: transmission
    1. Username//Password, same as used to log into web UI above
