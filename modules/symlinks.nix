{ config, lib, ... }:

with lib;

{

  options = {
    environment.binbash = mkOption {
      default = null;
      type = types.nullOr types.path;
      description = ''
        Include a /bin/bash in the system.
      '';
    };
  };

  config = {

    system.activationScripts.binbash = if config.environment.binbash != null
      then ''
        mkdir -m 0755 -p /bin
        ln -sfn ${config.environment.usrbinenv} /bin/.bash.tmp
        mv /bin/.bash.tmp /usr/bin/bash # atomically replace /usr/bin/env
      ''
      else ''
        rm -f /bin/bash
        rmdir -p /bin || true
      '';

  };

}