{ lib, user, ... }:

let
  mediaGroup = "media";

  library = "/media";
  data = "/data";
  scratch = "/var/cache";

  mounts = [ library data scratch ];

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
in
{
  services = {
    immich = {
      enable = true;
      host = "192.168.1.100";
      port = 2283;
      mediaLocation = "${data}/immich";
      accelerationDevices = [ "/dev/dri/renderD128" ];
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
        download-dir = "${library}/downloads/complete";
        incomplete-dir = "${library}/downloads/incomplete";
        incomplete-dir-enabled = true;
        watch-dir = "${library}/downloads/watch";
        watch-dir-enabled = true;
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.1.*";
        rpc-port = 8081;
        umask = "002";
      };
    };

    samba = {
      enable = true;
      openFirewall = true;
      nmbd.enable = false;
      winbindd.enable = false;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "dellakam";
          "map to guest" = "Never";
          "server min protocol" = "SMB3";
          security = "user";
          "netbios name" = "dellakam";
        };
        media = {
          path = library;
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
        movies = {
          path = "${data}/movies";
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
          path = "${library}/samba/public";
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
    bazarr.unitConfig.RequiresMountsFor = [ library data ];
    radarr.unitConfig.RequiresMountsFor = [ library data ];
    radarr.serviceConfig = mediaWriter // {
      PrivateUsers = lib.mkForce false;
    };
    sonarr.unitConfig.RequiresMountsFor = [ library ];
    sonarr.serviceConfig = mediaWriter // {
      PrivateUsers = lib.mkForce false;
    };
    transmission = {
      requires = [ "transmission-setup.service" ];
      unitConfig.RequiresMountsFor = [ library ];
    };
    transmission-setup.unitConfig.RequiresMountsFor = [ library ];
    plex = {
      unitConfig.RequiresMountsFor = mounts;
      serviceConfig.SupplementaryGroups = [ "render" "video" ];
      environment.PLEX_MEDIA_SERVER_TMPDIR = lib.mkForce "${scratch}/plex";
    };
    immich-server.unitConfig.RequiresMountsFor = [ data ];
    immich-machine-learning.unitConfig.RequiresMountsFor = [ data ];
    samba-smbd.unitConfig.RequiresMountsFor = [ library data ];
  };

  systemd.tmpfiles.settings."10-media" = {
    "${library}" = sharedDirectory;
    "${data}" = sharedDirectory;
    "${data}/movies" = sharedDirectory;
    "${library}/series" = sharedDirectory;
    "${library}/downloads" = sharedDirectory;
    "${library}/downloads/complete" = sharedDirectory;
    "${library}/downloads/complete/radarr" = sharedDirectory;
    "${library}/downloads/complete/tv-sonarr" = sharedDirectory;
    "${library}/downloads/incomplete" = sharedDirectory;
    "${library}/downloads/watch" = sharedDirectory;
    "${library}/samba" = sharedDirectory;
    "${library}/samba/public" = sharedDirectory;
    "${scratch}/plex".d = { mode = "0700"; user = "plex"; group = "plex"; };
    "${data}/immich".d = { mode = "0700"; user = "immich"; group = "immich"; };
  };

  systemd.services.systemd-tmpfiles-setup.unitConfig.RequiresMountsFor = mounts;
  systemd.services.systemd-tmpfiles-resetup.unitConfig.RequiresMountsFor = mounts;

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
