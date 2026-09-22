{
  description = "NixOS rolling para PC y Netbook: GNOME, LSFG por aplicación y edición científica";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    determinate.url = "github:DeterminateSystems/determinate/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lsfg-vk = {
      url = "git+https://git.lsfg-vk.dev/lsfg-vk.git?ref=master";
      flake = false;
    };

    freesmlauncher = {
      url = "github:FreesmTeam/FreesmLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hytale-launcher = {
      url = "github:JPyke3/hytale-launcher-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-nixcord.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    gnome-vram-booster = {
      url = "github:sachesi/gnome-vram-booster/main";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      updatePkgs = nixpkgs.legacyPackages.${system};
      update = updatePkgs.writeShellApplication {
        name = "update";
        runtimeInputs = [
          updatePkgs.nix
          updatePkgs.nix-update
        ];
        text = ''
          nix flake update
          # Excluir las etiquetas de subpaquetes, como pandoc-cli-3.11.
          nix-update --flake pandoc-quarto --version=stable \
            --version-regex '^([0-9]+(?:[.][0-9]+)+)$' \
            --override-filename Packages/Pandoc.nix
        '';
      };

      overlays = [
        inputs.nix-vscode-extensions.overlays.default
        inputs.freesmlauncher.overlays.default

        (final: _: {
          pandoc-quarto = final.callPackage ./Packages/Pandoc.nix { };

          gnome-vram-booster = final.callPackage ./Packages/Gnome-Vram-Booster.nix {
            src = inputs.gnome-vram-booster;
          };

          lsfg-vk = final.callPackage ./Packages/LSFG-VK.nix {
            src = inputs.lsfg-vk;
          };
        })

        (_: _: {
          hytale-launcher = inputs.hytale-launcher.packages.${system}.default;
        })
      ];

      baseModules = [
        inputs.determinate.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.impermanence.nixosModules.impermanence
        inputs.sops-nix.nixosModules.sops
        inputs.chaotic.nixosModules.default
        inputs.nix-gaming.nixosModules.platformOptimizations
        inputs.nix-gaming.nixosModules.pipewireLowLatency
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit inputs;
            };
            sharedModules = [
              inputs.chaotic.homeManagerModules.default
              inputs.nixcord.homeModules.nixcord
            ];
          };
        }
        {
          nixpkgs.overlays = overlays;
        }
      ];

      mkHost =
        hostModule: homeModule:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = baseModules ++ [
            hostModule
            { home-manager.users.bin = homeModule; }
          ];
        };
    in
    {
      formatter.${system} = updatePkgs.nixfmt;

      packages.${system} = {
        inherit update;
        pandoc-quarto = updatePkgs.callPackage ./Packages/Pandoc.nix { };
      };

      apps.${system}.update = {
        type = "app";
        program = "${update}/bin/update";
        meta.description = "Actualizar la flake y Pandoc a su última versión estable";
      };

      nixosConfigurations = {
        PC = mkHost ./Hosts/PC/configuration.nix ./Hosts/PC/home.nix;
        Netbook = mkHost ./Hosts/Netbook/configuration.nix ./Hosts/Netbook/home.nix;
      };
    };
}
