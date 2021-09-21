Create Initrd for Crypto Keyfiles
---------------------------------

    # dd if=/dev/urandom of=./crypto_keyfiles/my_keyfile_01.bin bs=1024 count=4

    # cryptsetup luksAddKey /dev/sdXY ./crypto_keyfiles/my_keyfile_01.bin

    # ./scripts/make_initrd_for_keys.sh crypto_keyfiles/ /mnt/boot/initrd.keys.gz



Example Snippets
----------------

### Get a specific Module from `unstable` Channel

First add the channel:

```bash
$ sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
```

Then replace the module:

```nix
{ config, pkgs, ... }:

let
  baseconfig = { allowUnfree = true; };
  unstable = import <nixos-unstable> { config = baseconfig; };
in
{
  disabledModules = [
    "services/networking/unify.nix"
  ];
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <nixos-unstable/nixos/modules/services/networking/unify.nix>
  ];

  nixpkgs.config = baseconfig;

  # This also replaces the packages when they are used as dependency for other
  # packages
  nixpkgs.config.packageOverrides = pkgs: {
    unify = unstable.unify;

    # NOTE: It might be necessary to add `unstable = unstable;` or
    #       `inherit unstable;` here to make the below `unstable.nvim` work.
  };

  environment.systemPackages = with pkgs; [
    # Get package specifically from `unstable`
    unstable.nvim

    # This package has been replaced with the version from `unstable`
    unify
  ];
```



### Get a specific Package from a Pull Request

```nix
{ config, pkgs, ... }:

let
  pr_ksnip = import (builtins.fetchTarball {
    name = "nixos-pr_ksnip";
    url = "https://api.github.com/repos/x3rAx/nixpkgs/tarball/ksnip-1.9.1";
    sha256 = "0qxx4kvmka3ykjnlqbdfapymb8k16adznh3ihf9gabzcy5mbavbr";
  }) { };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # This also replaces the package when it is used as dependency for other
  # packages
  nixpkgs.config.packageOverrides = pkgs: {
    ksnip = pr_ksnip.ksnip;
  };
}
```
