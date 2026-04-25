{ ... }:

{
  networking = {
    hostName = "dellakam";
    nameservers = [ "208.67.220.220" "158.64.1.29" ];
    enableIPv6 = false;
    # # Enable bridge mode for the VM
    # bridges.br0.interfaces = [ "enp3s0" ];
    # interfaces.br0.useDHCP = true;

    interfaces.enp3s0.ipv4.addresses = [
      {
        address = "192.168.2.100";
        prefixLength = 24;
      }
    ];

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
  };
}
