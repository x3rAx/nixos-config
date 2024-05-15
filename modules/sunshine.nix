# Configuration for workstations (desktops / laptops)
{ config, pkgs, lib, utils, myLib, inputs, ... }@args:

let
    nixpkgs-config = { allowUnfree = true; };

    sunshine-pkg = pkgs.sunshine.override {
        #cudaSupport = true;
    };

in rec {
# --- START: This part is the attempt to use the unstable module ---
    #imports = [
    #    (import "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/sunshine.nix" { inherit config lib utils; pkgs = pkgs.unstable; })
    #];
    ##system.extraSystemBuilderCmds = myLib.createCopyExtraConfigFilesScript imports;

    #services.sunshine = {
    #    enable = true;
    #    autoStart = false;
    #    capSysAdmin = true;
    #    openFirewall = true;
    #};
# --- END: This part is the attempt to use the unstable module ---

    environment.systemPackages = with pkgs; [
        sunshine-pkg
        moonlight-qt #for testing purposes.
    ];

    security.wrappers.sunshine = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+p";
        source = "${sunshine-pkg}/bin/sunshine";
    };

    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 47984 47989 47990 48010 ];
        allowedUDPPortRanges = [
        { from = 47998; to = 48000; }
        #{ from = 8000; to = 8010; }
        ];
    };
}

