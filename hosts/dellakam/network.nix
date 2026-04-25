{ lib, ... }:

{
  networking = {
    hostName = "dellakam";
    nameservers = [ "208.67.220.220" "158.64.1.29" ];
    enableIPv6 = false;
    # # Enable bridge mode for the VM
    # bridges.br0.interfaces = [ "enp3s0" ];
    # interfaces.br0.useDHCP = true;

    wireless.enable = lib.mkForce false;
    useDHCP = false;
    defaultGateway = {
      address = "192.168.2.1";
      interface = "enp3s0";
    };
    interfaces.enp3s0.ipv4.addresses = [
      {
        address = "192.168.2.100";
        prefixLength = 24;
      }
    ];

    # Enable networking
    networkmanager = {
      enable = true;
      unmanaged = [ "enp3s0" ];
      ensureProfiles.profiles.enp2s0 = {
        connection = {
          id = "enp2s0";
          type = "ethernet";
          interface-name = "enp2s0";
          autoconnect = true;
        };
        ipv4 = {
          method = "auto";
          route-metric = 500;
        };
        ipv6.method = "disabled";
      };
    };

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
  };
}
