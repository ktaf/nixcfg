{ ... }:

{
  networking = {
    hostName = "dellakam";
    nameservers = [ "208.67.220.220" "158.64.1.29" ];
    enableIPv6 = false;
    wireless.enable = false;
    useDHCP = false;
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp2s0";
    };
    interfaces.enp2s0 = {
      ipv4.addresses = [{
        address = "192.168.1.100";
        prefixLength = 24;
      }];
      wakeOnLan.enable = true;
    };
    firewall.enable = false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };
}
