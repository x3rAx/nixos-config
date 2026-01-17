{myLib, ...}: rec {
  imports = [
    ./ios-usb.nix
    ./programs/lutris.nix
    ./programs/neovim.nix
    ./programs/nixos-rebuild-wrapper.nix
  ];
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;
}
