{ pkgs, user, ... }:

{
  networking = {
    hostName = "dellakam";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    enableIPv6 = true;
    # Enable bridge mode for the VM
    bridges.br0.interfaces = [ "enp3s0" ];
    interfaces.br0.useDHCP = true;

    # Enable networking
    networkmanager.enable = true;

    # Enable IP forwarding
    firewall = {
      enable = false;
    };
  };
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };
    # samba-wsdd = {
    #   enable = true;
    #   openFirewall = true;
    #   workgroup = "WORKGROUP"; # optional override
    #   hostname = "dellakam"; # optional, defaults to hostName
    # };
    # samba = {
    #   enable = true;
    #   package = pkgs.samba4Full;
    #   openFirewall = true;
    #   nsswins = true;
    #   nmbd.enable = true;
    #   settings = {
    #     global = {
    #       workgroup = "WORKGROUP";
    #       "server string" = "dellakam";
    #       "map to guest" = "Never";
    #       "server min protocol" = "SMB3";
    #       security = "user";
    #       "netbios name" = "dellakam";
    #       "os level" = "65";
    #       "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=262144 SO_SNDBUF=262144";
    #       "use sendfile" = "yes";
    #       "aio read size" = "16384";
    #       "aio write size" = "16384";
    #       "max xmit" = "131072";
    #       "kernel oplocks" = "no";
    #       "level2 oplocks" = "no";
    #     };
    #     public = {
    #       path = "/data/samba/public";
    #       browseable = "yes";
    #       "read only" = "no";
    #       "guest ok" = "no";
    #       "force user" = "win";
    #       "force group" = "win";
    #       "valid users" = "win";
    #       "create mask" = "0664";
    #       "directory mask" = "0775";
    #     };
    #   };
    # };
  };
  # Ensure directory exists with correct ownership/permissions
  systemd.tmpfiles.rules = [
    "d /data/samba/public 0775 win win -"
  ];

  users.groups.win = { };
  users.users."win" = {
    isSystemUser = true;
    group = "win";
    home = "/var/empty";
    shell = "/run/current-system/sw/bin/nologin";
  };
}
