{ ... }:

{
  networking = {
    hostName = "arvanix";
    nameservers = [ "87.107.110.109" "87.107.110.110" ];
    enableIPv6 = true;

    # Enable IP forwarding
    firewall.enable = false;
    nat.enable = true;
    nat.internalInterfaces = [ "tun0" "ipip0" ];
    nat.externalInterface = "enp3s0";

    # 6to4 tunnel configuration
    sits = {
      "6to4" = {
        remote = "90.190.123.24"; # Replace with your Mikrotik's domain
        local = "185.226.118.126"; # Replace with your NixOS server's domain
        ttl = 255;
        dev = "sit0"; # Specify a device name
      };
    };
  };
}
