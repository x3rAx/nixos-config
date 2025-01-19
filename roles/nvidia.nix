{
  config,
  pkgs,
  ...
}: {
  # NVIDIA drivers are unfree.
  #nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.graphics.enable = true;

  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  # See here:
  #   https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
  # for a list of available packages.
  # - stable     = `latest` (or `legacy_390` if host platform is 'i686-linux')
  # - latest     = "New Feature Branch" (or `production` which ever is newer)
  # - production = "Production Branch"
  # The default is `stable`.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  hardware.nvidia.open = true;

  # TODO: Maybe remove again - Fix for "V rising" to get nvidia driver from unstable
  #boot.kernelPackages = pkgs.unstable.linuxPackages;
}
