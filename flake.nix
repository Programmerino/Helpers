{
  description = "Helpers";

  nixConfig.bash-prompt = "\[nix-develop\]$ ";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.dotnet.url = "github:Programmerino/dotnet-nix";
  outputs = { self, nixpkgs, flake-utils, dotnet }:
    flake-utils.lib.eachSystem(["x86_64-linux" "aarch64-linux"]) (system:
      let
        pkgs = import nixpkgs { 
          inherit system;
        };
        name = "Helpers";
        version = let _ver = builtins.getEnv "GITVERSION_NUGETVERSIONV2"; in if _ver == "" then "0.0.0" else "${_ver}.${builtins.getEnv "GITVERSION_COMMITSSINCEVERSIONSOURCE"}";
        sdk = pkgs.dotnet-sdk;
        library = true;

      in rec {
          devShell = pkgs.mkShell {
            inherit name;
            inherit version;
            inherit library;
            DOTNET_CLI_HOME = "/tmp/dotnet_cli";
            buildInputs = defaultPackage.nativeBuildInputs ++ [sdk];
            DOTNET_ROOT = "${sdk}";
          };
    
          defaultPackage = dotnet.buildDotNetProject.${system} rec {
              inherit name;
              inherit version;
              inherit sdk;
              inherit system;
              inherit library;
              src = ./.;
              lockFile = ./packages.lock.json;
              configFile =./nuget.config;

              nativeBuildInputs = [
                pkgs.clang_12
              ];

              nugetSha256 = "sha256-tX6zyiPkJguBW2PRqDmpSCNQCY1E+2OYdroHKDP0ZRI=";
          };

      }
    );
}