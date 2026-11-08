{ ... }:

let
  lan = "lan0";
in
{
  # Name the NIC by MAC, not PCI slot: a PCIe card moves it from bus 02 to 03
  systemd.network.links."10-${lan}" = {
    matchConfig.PermanentMACAddress = "d8:9e:f3:30:a2:68";
    linkConfig = {
      Name = lan;
      WakeOnLan = "magic";
    };
  };

  networking = {
    hostName = "dellakam";
    nameservers = [ "208.67.220.220" "158.64.1.29" ];
    enableIPv6 = false;
    wireless.enable = false;
    useDHCP = false;
    defaultGateway = {
      address = "192.168.1.1";
      interface = lan;
    };
    interfaces.${lan}.ipv4.addresses = [{
      address = "192.168.1.100";
      prefixLength = 24;
    }];
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
