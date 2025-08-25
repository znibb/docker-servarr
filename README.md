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
  - [2.7. Jellyfin](#27-jellyfin)
  - [2.8. Jellyseerr](#28-jellyseerr)

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

### 2.7 Jellyfin
#### 2.7.1 Authentik Setup
1. Open the Authentik Admin Interface
1. Go to `Applications->Providers` and click `Create`
1. Select `OAuth2/OpenID Provider` and click `Next`
1. Enter the following:
   - Name: `Jellyfin Provider`
   - Authorization flow: implicit-consent
   - Client type: `Confidential`
   - Redirect URIs/Origins (RegEx): `https://jellyfin.DOMAIN.COM/sso/OID/redirect/authentik`
   - Subject mode: `Based on the User's username`
1. Take note of your `Client ID` and `Client Secret`, you will need these in the SSO plugin setup in Jellyfin
1. Click `Finish`
1. Go to `Applications->Applications` and click `Create`
1. Enter the following:
   - Name: `Jellyfin`
   - Slug: `jellyfin`
   - Provider: `Jellyfin Provider`
1. (Optional) If you want to suppress Jellyfin being listed in the Authentik User Interface set `Launch URL` to `blank://blank`
1. Click `Create`

#### 2.7.2 Jellyfin Setup
1. Go to your Jellyfin web UI and set up your initial/admin account
1. Log in with said account, click on the hamburger menu in the top-left corner and click on `Administration->Dashboard`
1. In the left-side menu click on `Plugins->Catalog` and then on the cog icon at the top
1. Click on the plus icon at the top and enter:
    - Repository Name: `SSO AUthentication`
    - Repository URL: `https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json`
1. Click on `Save`
1. Go back to the `Catalog` view and under the `Authentiation Provider` section you should find `SSO Authentication`, click on it and install/enable the plugin
1. Restart you jellyfin container with `docker compose restart jellyfin`
1. Go back to `Plugins->My Plugins` and click on `SSO-Auth`
1. Create a provider and enter the following:
    - Name: `authentik` (CASE IMPORTANT)
    - OID Endpoint: `https://auth.DOMAIN.COM/application/o/jellyfin/.well-known/openid-configuration`
    - OpenID Client ID: Client ID as per the Authentik Setup
    - OID Secret: Client Secret as per the Authentik Setup
    - Enabled: **ON**
    - Enable Authorization by Plugin: **ON**
    - Scheme Override: `https`
1. Scroll to the bottom and click `Save`
1. Go to `General` in the left-side menu and scroll down to `Branding`
1. Input the following under `Login disclaimer`:
    ```
    <form action="https://jellyfin.DOMAIN.COM/sso/OID/start/authentik">
        <button class="raised block emby-button button-submit">
            Sign in with SSO
        </button>
    </form>
    ```
1. Input the following under `Custom CSS code`:
    ```
    a.raised.emby-button {
        padding:0.9em 1em;
        color: inherit !important;
    }

    .disclaimerContainer{
        display: block;
    }
    ```
1. If you want to be able to use Quick Connect to connect to e.g. TVs etc make sure that `Enable Quick Connect on this server` is enabled
1. Click `Save`

When signing in to Jellyfin there should now be a button at the bottom for `Sign in with SSO`

## 2.8 Jellyseerr
Jellyseerr needs to connect to the Jellyfin server with an account that has admin rights, use the Jellyfin `admin` user you set up earlier.

#### 2.8.1 Authentik
1. Open the Authentik Admin Interface
1. Go to `Applications->Providers` and click `Create`
1. Select `OAuth2/OpenID Provider` and click `Next`
1. Enter the following:
   - Name: `Jellyseerr Provider`
   - Authorization flow: implicit-consent
   - Client type: `Confidential`
   - Redirect URIs/Origins (RegEx): `^https://jellyseerr\.DOMAIN\.COM/login\?provider=authentik&callback=true.*`
   - Subject mode: `Based on the User's username`
1. Take note of your `Client ID` and `Client Secret`, you will need these in the SSO plugin setup in Jellyfin
1. Click `Finish`
1. Go to `Applications->Applications` and click `Create`
1. Enter the following:
   - Name: `Jellyseerr`
   - Slug: `jellyseerr`
   - Provider: `Jellyseerr Provider`
1. (Optional) If you want to suppress Jellyfin being listed in the Authentik User Interface set `Launch URL` to `blank://blank`
1. Click `Create`

#### 2.8.2 Jellyseerr
1. When you first load the page you're met with the setup wizard, click `Configure Jellyfin`
1. Enter:
    - Jellyfin URL: `http://jellyfin:8096`
    - Base URL: Leave blank
    - Email: Not related to Jellyfin, use whatever
    - Username: `admin`
    - Password: The password you set up for the Jellyfin `admin` user previously
1. Click `Sign in` at the bottom
1. Click `Sync Libraries` and toggle them on, click `Continue` at the bottom
1. Radarr Settings:
    - Default Server: Check
    - Server Name: Radarr
    - Hostname: radarr
    - Port: 7878
    - API Key: Get from Radarr Settings->General
    - Click `Test` at the bottom
    - Quality Profile: Any
    - Root Folder: /data/movies
    - Enable Scan: Check
    - Tag Requests: Check
1. Click `Add Server` at the bottom
1. Sonarr Settings:
    - Default Server: Check
    - Server Name: Sonarr
    - Hostname: sonarr
    - Port: 8989
    - API Key: Get from Sonarr Settings->General
    - Click `Test` at the bottom
    - Quality Profile: Any
    - Root Folder: /data/tv
    - Season Folders: Check
    - Tag Requests: Check
1. Click `Finish Setup` at the bottom
1. Go to `Settings->Users`
1. Uncheck `Enable Local Sign-In` and check `Enable OpenID Connect Sign-In`
1. In the popup that appears click `Add OpenID Connect Provider` and fill out:
    - Provider Name: Authentik
    - Logo: `https://cdn.jsdelivr.net/gh/selfhst/icons/svg/authentik.svg`
    - Issuer URL: `https://auth.DOMAIN.COM/application/o/jellyseerr`
    - Client ID: Get from Authentik Provider
    - Client Secret: Get from Authentik Provider
    - Provider Slug: `authentik`
    - Scopes: `email openid profile` (it says `Comma-separated` but use spaces)
    - Allow New Users: Check
1. Click `Save Changes` at the bottom, then close the `Configure OpenID Connect` window by clicking `Close`
1. Finally go to the bottom and click `Save Changes`