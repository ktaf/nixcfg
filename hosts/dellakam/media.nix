{ lib, pkgs, user, ... }:

let
  mediaGroup = "media";

  mediaWriter = {
    UMask = lib.mkForce "0002";
  };

  sharedDirectory = {
    d = {
      mode = "2775";
      user = "root";
      group = mediaGroup;
    };
  };

  sharedTree = sharedDirectory // {
    Z = {
      mode = "~2775";
      group = mediaGroup;
    };
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
      group = mediaGroup;
      settings = {
        download-dir = "/data/downloads/complete";
        incomplete-dir = "/data/downloads/incomplete";
        incomplete-dir-enabled = true;
        watch-dir = "/data/downloads/watch";
        watch-dir-enabled = true;
        openFirewall = true;
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.2.*";
        rpc-port = 8081;
        umask = "002";
      };
    };

    # samba-wsdd = {
    #   enable = true;
    #   openFirewall = true;
    #   workgroup = "WORKGROUP";
    #   hostname = "dellakam";
    # };

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
          "force group" = mediaGroup;
          "valid users" = "win";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force directory mode" = "2775";
        };
      };
    };
  };

  systemd.services = {
    bazarr.serviceConfig = mediaWriter;
    radarr.serviceConfig = mediaWriter // {
      PrivateUsers = lib.mkForce false;
    };
    sonarr.serviceConfig = mediaWriter // {
      PrivateUsers = lib.mkForce false;
    };
    transmission.requires = [ "transmission-setup.service" ];
  };

  systemd.tmpfiles.settings."10-media" = {
    "/data" = sharedDirectory;
    "/data/samba" = sharedDirectory;
    "/data/samba/public" = sharedTree;
    "/data/downloads" = sharedTree;
    "/data/downloads/complete" = sharedDirectory;
    "/data/downloads/complete/tv-sonarr" = sharedDirectory;
    "/data/downloads/complete/radarr" = sharedDirectory;
    "/data/downloads/incomplete" = sharedDirectory;
    "/data/downloads/watch" = sharedDirectory;
  };

  users.groups.${mediaGroup}.members = [
    user
    "sonarr"
    "radarr"
    "bazarr"
    "plex"
  ];

  users.users.win = {
    isSystemUser = true;
    group = mediaGroup;
    home = "/var/empty";
    shell = "/run/current-system/sw/bin/nologin";
  };
}
