{ ... }:

{
  networking = {
    hostName = "bc-250";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    enableIPv6 = true;

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
