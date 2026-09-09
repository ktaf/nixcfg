{ pkgs, user, ... }:

{

  # Add user to libvirtd group
  users.users.${user}.extraGroups = [ "libvirtd" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    qemu_kvm
    virtio-win
    win-spice
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
    docker.enable = true;
  };
  services.spice-vdagentd.enable = true;

}
