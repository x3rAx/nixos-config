{myLib, ...}: rec {
  imports = [
    ./ios-usb.nix
    ./programs/lutris.nix
    ./programs/neovim.nix
    ./programs/nixos-rebuild-wrapper.nix
    ./programs/steam.nix
  ];
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;
}
