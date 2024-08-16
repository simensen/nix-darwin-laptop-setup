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
      nixpkgs.url = "github:NixOS/nixpkgs";

      home-manager = {                                                      # User Environment Manager
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      darwin = {                                                            # MacOS Package Management
        url = "github:lnl7/nix-darwin/master";
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
    in
    {
      darwinConfigurations = (                                              # Darwin Configurations
      import ./darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager darwin vars;
        }
      );
    };
}
