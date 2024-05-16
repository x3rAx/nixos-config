# https://nixos.wiki/wiki/IOS
{pkgs, ...}: {
  # Support iOS USB storage and tethering
  services.usbmuxd.enable = true;
  environment.systemPackages = with pkgs; [
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'
  ];
}
