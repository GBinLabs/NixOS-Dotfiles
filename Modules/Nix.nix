{
  config,
  inputs,
  lib,
  ...
}:
{
  nix = {
    # Las instalaciones temporales usan la misma base que el sistema.
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      max-jobs = if config.Boot-Netbook.enable then 1 else "auto";
      cores = if config.Boot-Netbook.enable then 2 else 0;

      allowed-users = [
        "bin"
      ];

      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://freesmlauncher.cachix.org"
      ];

      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
      ];
    };

    optimise.automatic = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "lsfg-vk"
      "discord"
      "obsidian"
      "vscode"
      "vscode-extension-ms-python-vscode-pylance"
    ];
}
