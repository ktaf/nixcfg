{ ... }:

{
  networking = {
    hostName = "walter";
    nameservers = [ "208.67.220.220" "158.64.1.29" ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
    firewall.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };
}
