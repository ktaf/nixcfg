{ ... }:

{
  networking = {
    hostName = "ed800";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    enableIPv6 = true;
    # Enable bridge mode for the VM
    bridges.br0.interfaces = [ "enp4s0" ];
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
    samba = {
      enable = true;
      openFirewall = true;
      nsswins = true;
      nmbd.enable = true;
      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "ED800";
          "map to guest" = "Bad User";
          "guest account" = "nobody";
          security = "user";
        };
        public = {
          path = "/data/samba/public";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "force user" = "nobody";
          "force group" = "nogroup";
          "create mask" = "0666";
          "directory mask" = "0777";
        };
      };
    };
  };
  # Ensure directory exists with correct ownership/permissions
  systemd.tmpfiles.rules = [
    "d /data/samba/public 0777 nobody nogroup -"
  ];
}
