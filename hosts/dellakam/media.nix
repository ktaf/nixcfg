{ lib, pkgs, ... }:

let
  dataWriter = {
    SupplementaryGroups = [ "win" ];
    UMask = lib.mkForce "0002";
    PrivateUsers = lib.mkForce false;
  };
in
{
  services = {
    immich = {
      enable = true;
      host = "192.168.2.100";
      port = 2283;
      machine-learning.enable = true;
      database.enable = true;
    };

    plex = {
      enable = true;
      openFirewall = true;
    };
    overseerr.enable = true;

    sabnzbd.enable = true;

    sonarr.enable = true;
    radarr = {
      enable = true;
      dataDir = "/var/lib/radarr";
    };
    bazarr.enable = true;
    flaresolverr.enable = true;
    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    transmission = {
      enable = true;
      group = "win";
      downloadDirPermissions = "2775";
      settings = {
        download-dir = "/data/downloads/complete";
        incomplete-dir = "/data/downloads/incomplete";
        incomplete-dir-enabled = true;
        watch-dir = "/data/downloads/watch";
        watch-dir-enabled = true;
        rpc-port = 8081;
        umask = "002";
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
      workgroup = "WORKGROUP";
      hostname = "dellakam";
    };

    samba = {
      enable = true;
      package = pkgs.samba4Full;
      openFirewall = true;
      nsswins = true;
      nmbd.enable = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "dellakam";
          "map to guest" = "Never";
          "server min protocol" = "SMB3";
          security = "user";
          "netbios name" = "dellakam";
          "os level" = "65";
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=262144 SO_SNDBUF=262144";
          "use sendfile" = "yes";
          "aio read size" = "16384";
          "aio write size" = "16384";
          "max xmit" = "131072";
          "kernel oplocks" = "no";
          "level2 oplocks" = "no";
        };
        public = {
          path = "/data/samba/public";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "force user" = "win";
          "force group" = "win";
          "valid users" = "win";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force directory mode" = "2775";
        };
      };
    };
  };

  systemd.services = {
    bazarr.serviceConfig = dataWriter;
    radarr.serviceConfig = dataWriter;
    sabnzbd.serviceConfig = dataWriter;
    sonarr.serviceConfig = dataWriter;
    plex.serviceConfig = {
      SupplementaryGroups = [ "win" ];
      PrivateUsers = lib.mkForce false;
    };
    transmission = {
      requires = [ "transmission-setup.service" ];
      serviceConfig = {
        UMask = lib.mkForce "0002";
        PrivateUsers = lib.mkForce false;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "z /var/lib/radarr 0700 radarr radarr -"
    "d /var/lib/sonarr 0750 sonarr sonarr -"
    "z /var/lib/sonarr 0750 sonarr sonarr -"
    "d /var/lib/sonarr/.config 0750 sonarr sonarr -"
    "z /var/lib/sonarr/.config 0750 sonarr sonarr -"
    "d /var/lib/sonarr/.config/NzbDrone 0750 sonarr sonarr -"
    "Z /var/lib/sonarr/.config/NzbDrone - sonarr sonarr -"
    "Z /var/lib/bazarr - bazarr bazarr -"
    "Z /var/lib/sabnzbd - sabnzbd sabnzbd -"
    "d /data 2775 win win -"
    "z /data 2775 win win -"
    "d /data/samba 2775 win win -"
    "z /data/samba 2775 win win -"
    "d /data/samba/public 2775 win win -"
    "z /data/samba/public 2775 win win -"
    "d /data/downloads 2775 win win -"
    "z /data/downloads 2775 win win -"
    "d /data/downloads/complete 2775 transmission win -"
    "z /data/downloads/complete 2775 transmission win -"
    "d /data/downloads/complete/tv-sonarr 2775 transmission win -"
    "z /data/downloads/complete/tv-sonarr 2775 transmission win -"
    "d /data/downloads/complete/movies-radarr 2775 transmission win -"
    "z /data/downloads/complete/movies-radarr 2775 transmission win -"
    "d /data/downloads/incomplete 2775 transmission win -"
    "z /data/downloads/incomplete 2775 transmission win -"
    "d /data/downloads/watch 2775 transmission win -"
    "z /data/downloads/watch 2775 transmission win -"
  ];

  users.groups.win = { };
  users.users.win = {
    isSystemUser = true;
    group = "win";
    home = "/var/empty";
    shell = "/run/current-system/sw/bin/nologin";
  };
}
