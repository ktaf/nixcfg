{ ... }:

{
  networking = {
    hostName = "walter";
    nameservers = [ "208.67.220.220" "158.64.1.29" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
    firewall = {
      enable = true;
      interfaces.enp3s0.allowedTCPPorts = [ 8000 8080 ];
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      settings = {
        server.allow-interfaces = [ "enp3s0" ];
        publish = {
          disable-publishing = false;
          publish-addresses = true;
        };
      };
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };
  };
}
