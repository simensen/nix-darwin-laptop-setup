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
      nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";                     # Unstable Nix Packages (Default)
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";         # Stable Nix Packages

      home-manager = {                                                      # User Environment Manager
        url = "github:nix-community/home-manager/release-23.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      darwin = {                                                            # MacOS Package Management
        url = "github:lnl7/nix-darwin/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, darwin, ... }:   # Function telling flake which inputs to use
    let
      vars = {                                                              # Variables Used In Flake
        user = "beausimensen";
        location = "$HOME/.setup";
        terminal = "wezterm";
        editor = "vim";
      };
    in
    {
      darwinConfigurations = (                                              # Darwin Configurations
        import ./darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-unstable home-manager darwin vars;
        }
      );
    };
}
