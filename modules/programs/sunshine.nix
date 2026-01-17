# Configuration for workstations (desktops / laptops)
{
  config,
  inputs,
  lib,
  myLib,
  pkgs,
  utils,
  ...
} @ args: let
  cfg = config.x3ro.programs.sunshine;

  nixpkgs-config = {allowUnfree = true;};

  sunshine-pkg = pkgs.sunshine.override {
    #cudaSupport = true;
  };
in {
  options = {
    x3ro.programs.sunshine = {
      enable = lib.mkEnableOption "Enable Sunshine, the game stream host for Moonlight";
    };
  };

  config = lib.mkIf cfg.enable rec {
    # --- START: This part is the attempt to use the unstable module ---
    #imports = [
    #    (import "${inputs.nixpkgs-unstable}/nixos/modules/services/networking/sunshine.nix" { inherit config lib utils; pkgs = pkgs.unstable; })
    #];
    ##system.systemBuilderCommands = myLib.createCopyExtraConfigFilesScript imports;

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
      enable = lib.mkDefault true;
      allowedTCPPorts = [47984 47989 47990 48010];
      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        #{ from = 8000; to = 8010; }
      ];
    };
  };
}
