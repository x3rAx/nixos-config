{myLib, ...}: rec {
  imports = [
    ./ios-usb.nix
    ./programs/lutris.nix
    ./programs/neovim.nix
  ];
  system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;
}
