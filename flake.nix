#
#  flake.nix *
#   ├─ ./hosts
#   │   └─ default.nix
#   ├─ ./darwin
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#

{
  description = "Nix Darwin System Flake Configuration";

  inputs =                                                                  # References Used by Flake
  {
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

      home-manager = {                                                      # User Environment Manager
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      darwin = {                                                            # MacOS Package Management
        url = "github:nix-darwin/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, home-manager, darwin, ... }:   # Function telling flake which inputs to use
    let
      vars = {                                                              # Variables Used In Flake
        user = "beausimensen";
        location = "$HOME/.setup";
        terminal = "wezterm";
        editor = "vim";
      };
      system = "aarch64-darwin";
      pkgs =  nixpkgs.legacyPackages."${system}";
      linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
      darwin-builder = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        modules = [
          "${nixpkgs}/nixos/modules/profiles/nix-builder-vm.nix"
          { virtualisation = {
              host.pkgs = pkgs;
              darwin-builder.workingDirectory = "/var/lib/darwin-builder";
              darwin-builder.hostPort = 22;
            };
          }
        ];
      };
    in
    {
      darwinConfigurations = (                                              # Darwin Configurations
      import ./darwin {
          inherit (nixpkgs) lib;
          inherit system linuxSystem inputs nixpkgs home-manager darwin vars;
        }
      );
    };
}
