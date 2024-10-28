{ ... }: {

  services.hypridle = {
    enable = true;
    settings =
      {
        general = {
          before_sleep_cmd = "playerctl pause && swaylock";
          lock_cmd = "swaylock";
        };
        listener = [
          {
            timeout = 300;
            on-timeout = "swaylock";
          }
          {
            timeout = 600;
            on-timeout = "systemctl suspend";
          }
        ];
      };
  };
}
