{ config, lib, pkgs, user, ... }:

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
      accelerationDevices = [ "/dev/dri/renderD128" ];
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
      openPeerPorts = true;
      settings = {
        download-dir = "/data/downloads/complete";
        incomplete-dir = "/data/downloads/incomplete";
        incomplete-dir-enabled = true;
        watch-dir = "/data/downloads/watch";
        watch-dir-enabled = true;
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.2.*";
        rpc-port = 8081;
        umask = "002";
      };
    };

    samba = {
      enable = true;
      package = pkgs.samba;
      openFirewall = true;
      nmbd.enable = false;
      winbindd.enable = false;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "walter";
          "map to guest" = "Never";
          "server min protocol" = "SMB3";
          security = "user";
          "netbios name" = "walter";
        };
        media = {
          path = "/media";
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
    bazarr = {
      serviceConfig = mediaWriter;
      unitConfig.RequiresMountsFor = [ "/data" "/media" ];
    };
    radarr.unitConfig.RequiresMountsFor = [ "/data" "/media" ];
    radarr.serviceConfig = mediaWriter // {
      PrivateUsers = lib.mkForce false;
    };
    sonarr.unitConfig.RequiresMountsFor = [ "/data" "/media" ];
    sonarr.serviceConfig = mediaWriter // {
      PrivateUsers = lib.mkForce false;
    };
    transmission = {
      requires = [ "transmission-setup.service" ];
      unitConfig.RequiresMountsFor = [ "/data" ];
    };
    transmission-setup.unitConfig.RequiresMountsFor = [ "/data" ];
    plex = {
      unitConfig.RequiresMountsFor = [ "/data" "/media" "/fast" ];
      serviceConfig.SupplementaryGroups = [ "render" "video" ];
      serviceConfig.ExecStartPre = lib.mkAfter [
        "${pkgs.python3}/bin/python3 ${./plex-preferences.py}"
      ];
      environment.PLEX_PREFERENCES = "${config.services.plex.dataDir}/Plex Media Server/Preferences.xml";
    };
    samba-smbd.unitConfig.RequiresMountsFor = [ "/data" "/media" ];
  };

  systemd.tmpfiles.settings."10-media" = {
    "/media" = sharedDirectory;
    "/media/movies" = sharedDirectory;
    "/media/series" = sharedDirectory;
    "/media/downloads" = sharedDirectory;
    "/media/downloads/complete" = sharedDirectory;
    "/media/downloads/incomplete" = sharedDirectory;
    "/media/downloads/watch" = sharedDirectory;
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
