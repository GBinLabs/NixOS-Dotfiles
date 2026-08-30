{
  description = "NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
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

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    freesmlauncher = {
      url = "github:FreesmTeam/FreesmLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hytale-launcher = {
      url = "github:JPyke3/hytale-launcher-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord.url = "github:4evy/nixcord";

    gnome-vram-booster = {
      url = "github:sachesi/gnome-vram-booster/main";
      flake = false;
    };
    
    sdl3-src = {
  url = "github:libsdl-org/SDL/main";
  flake = false;
};
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    baseModules = [
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
        nixpkgs.overlays = [
          inputs.nix-vscode-extensions.overlays.default
          inputs.freesmlauncher.overlays.default
          (final: _: {
            gnome-vram-booster = final.callPackage ./Packages/Gnome-Vram-Booster.nix {
              src = inputs.gnome-vram-booster;
            };
          })

          (final: prev: {
            hytale-launcher = inputs.hytale-launcher.packages.${system}.default;
          })
        ];
      }
    ];
    mkHost = hostModule: homeModule:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules =
          baseModules
          ++ [
            hostModule
            {home-manager.users.bin = homeModule;}
          ];
      };
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;

    nixosConfigurations = {
      PC = mkHost ./Hosts/PC/configuration.nix ./Hosts/PC/home.nix;
      Netbook = mkHost ./Hosts/Netbook/configuration.nix ./Hosts/Netbook/home.nix;
      #VM = mkHost ./Hosts/VM/configuration.nix ./Hosts/VM/home.nix;
    };
  };
}
