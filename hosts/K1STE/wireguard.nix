# This comment enables syntax highlighting in nvim 🤪
{
  config,
  pkgs,
  ...
}: {
  # TODO: Isnt this bad? Can we add an exception for wireguard instead?
  networking.firewall.checkReversePath = false;

  networking.wg-quick = {
    interfaces = {
      #"wg-x3ro" = {
      #  address = ["10.13.37.10/32"];
      #  # PulicKey: NvWlmzvVNzkr5ZAE10jRx6GVoDGn6mtizxc3gS5DOG8=
      #  privateKeyFile = "/etc/secrets/wireguard/private.key";
      #  dns = ["10.13.37.1"];

      #  peers = [
      #    {
      #      # jarvis.x3ro.net
      #      endpoint = "jarvis.x3ro.net:42420";
      #      publicKey = "oeA+nf/r+KLxLqtxRmzJ5WIQoAiCRj4ZbpstKHt023A=";
      #      presharedKeyFile = "/etc/secrets/wireguard/psks/psk#K1STE#jarvis.x3ro.net#.key";
      #      allowedIPs = ["10.13.37.0/24"];
      #      persistentKeepalive = 25;
      #    }
      #    #{ # badwolf.x3ro.net
      #    #    Endpoint = badwolf.x3ro.net:42420
      #    #    PublicKey = BaWDN4yJbBR/V0DpfTjQLNDGv/vSkL8gnqCK+XFDTyo=
      #    #    AllowedIPs = 10.13.37.2/32
      #    #}
      #  ];
      #};

      "wg_mfrdrvless" = {
        address = ["10.49.73.10/32"];
        # PublicKey: NvWlmzvVNzkr5ZAE10jRx6GVoDGn6mtizxc3gS5DOG8=
        privateKeyFile = "/etc/secrets/wireguard/private.key";

        peers = [
          {
            # jarvis.x3ro.net
            endpoint = "wireguard.x3ro.net:49731";
            publicKey = "oeA+nf/r+KLxLqtxRmzJ5WIQoAiCRj4ZbpstKHt023A=";
            presharedKeyFile = "/etc/secrets/wireguard/psks/psk#K1STE#jarvis.x3ro.net#.key";
            allowedIPs = ["10.49.73.0/24"];
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  services.resolved.enable = true;
}
