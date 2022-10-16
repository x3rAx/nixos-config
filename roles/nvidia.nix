{ config, pkgs, ... }:

let
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec -a "$0" "$@"
    '';
in {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        nvidia-offload
    ];

    #services.xserver.videoDrivers = [ "nvidia" ];
    #hardware.opengl.enable = true;

    #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Use the new Gallium `iris` driver for Intel graphics
    #--- REMOVE FROM HERE
    #environment.variables = {
    #    MESA_LOADER_DRIVER_OVERRIDE = "iris";
    #};
    #hardware.opengl.package = (pkgs.mesa.override {
    #    galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
    #}).drivers;
    #--- TO HERE
    #--- AND KEEP FROM HERE
    #environment.variables = {
    #    MESA_LOADER_DRIVER_OVERRIDE = "iris";
    #};
    #hardware.opengl = {
    #    enable = true;
    #    package = (pkgs.mesa.override {
    #        galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
    #    }).drivers;
    #    extraPackages = with pkgs; [
    #        intel-media-driver # LIBVA_DRIVER_NAME=iHD
    #        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    #        vaapiVdpau
    #        libvdpau-va-gl
    #    ];
    #};
    #--- TO HERE
  
    # --- WORKING CONFIG (put together with Anselm, disabled for debugging) ------
    #services.xserver.videoDrivers = [ "nvidia" ];
    #hardware.nvidia.prime = {
    #    offload.enable = true;
  
    #    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    #    intelBusId = "PCI:0:2:0";
  
    #    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    #    nvidiaBusId = "PCI:1:0:0";
    #};
    # --- END WORKING CONFIG -----------------------------------------------------

}
