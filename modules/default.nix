{myLib, ...}: rec {
  imports = [
    ./graphics/nvidia.nix

    ./hardware/ios-usb.nix

    ./programs/lutris.nix
    ./programs/neovim.nix
    ./programs/nixos-rebuild-wrapper.nix
    ./programs/steam.nix
    ./programs/sunshine.nix

    ./roles/common.nix
    ./roles/desktop
    ./roles/mostly-common.nix
    ./roles/server.nix
    ./roles/virtualisation.nix

    ./services/hdd-sleep.nix

    ./btrfs-swapfile.nix
  ];
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;
}
