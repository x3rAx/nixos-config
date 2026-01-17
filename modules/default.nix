{myLib, ...}: rec {
  imports = [
    ./hardware/ios-usb.nix

    ./programs/lutris.nix
    ./programs/neovim.nix
    ./programs/nixos-rebuild-wrapper.nix
    ./programs/steam.nix
    ./programs/sunshine.nix

    ./roles/common.nix
    ./roles/virtualisation.nix
  ];
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;
}
