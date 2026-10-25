{ inputs, pkgs, ... }:

let
  cuManager = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.bc250-cu-live-manager;
in
{
  environment.systemPackages = [ cuManager ];

  specialisation."40cu".configuration = {
    system.nixos.tags = [ "40cu" ];

    systemd.services.bc250-40cu-unlock = {
      description = "Enable BC-250 40-CU runtime dispatch";
      wantedBy = [ "multi-user.target" ];
      wants = [ "systemd-udev-settle.service" ];
      after = [ "systemd-udev-settle.service" ];
      before = [
        "systemd-user-sessions.service"
        "cyan-skillfish-governor-smu.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cuManager}/bin/bc250-cu-live-manager --yes enable all";
        RemainAfterExit = true;
        TimeoutStartSec = 60;
      };
    };
  };
}
