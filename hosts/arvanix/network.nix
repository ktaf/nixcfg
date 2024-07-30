{ config, pkgs, ... }:

{
  networking = {
    hostName = "arvanix";
    nameservers = [ "45.90.28.154" "45.90.30.154" "2a07:a8c0::18:68b2" "2a07:a8c1::18:68b2" ];

    # Enable IP forwarding
    firewall.enable = false;
    nat.enable = true;
    nat.internalInterfaces = [ "tun0" "ipip0" ];
    nat.externalInterface = "enp3s0";

    # 6to4 tunnel configuration
    sits = {
      "6to4" = {
        remote = "90.190.123.24";  # Replace with your Mikrotik's domain
        local = "185.226.118.126";      # Replace with your NixOS server's domain
        ttl = 255;
        dev = "sit1";  # Specify a device name
      };
    };
  };
}
