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
    firewall.enable = false;
  };
}
