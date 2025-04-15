#
#  These are the different profiles that can be used when building on MacOS
#
#  flake.nix
#   └─ ./darwin
#       ├─ default.nix *
#       └─ <host>.nix
#

{ lib, system, linuxSystem, inputs, nixpkgs, darwin, home-manager, vars, ...}:

let
  system = "aarch64-darwin";                                 # System Architecture
  #system = "x86_64-darwin";                                 # System Architecture
in
{
  fluke = darwin.lib.darwinSystem {                       #
    inherit system;
    specialArgs = { inherit inputs vars; };
    modules = [                                             # Modules Used
      {
        nix.distributedBuilds = true;
        nix.buildMachines = [{
              hostName = "localhost";
              sshUser = "builder";
              sshKey = "/etc/nix/builder_ed25519";
              system = "aarch64-linux";
              maxJobs = 4;
              supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
          }];
      }

      ./fluke.nix
      
      home-manager.darwinModules.home-manager {             # Home-Manager Module
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
