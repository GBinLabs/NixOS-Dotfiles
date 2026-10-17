{
  config,
  inputs,
  lib,
  ...
}:
{
  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      max-jobs = if config.Boot-Netbook.enable then 1 else "auto";
      cores = if config.Boot-Netbook.enable then 2 else 0;

      trusted-users = [
        "root"
        "bin"
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
      "open-webui"
      "lsfg-vk"
      "discord"
      "discord-unwrapped"
      "obsidian"
      "vscode"
      "vscode-extension-ms-python-vscode-pylance"
    ];
}
