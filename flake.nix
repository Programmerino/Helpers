{
  description = "Helpers";

  nixConfig.bash-prompt = "\[nix-develop\]$ ";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.dotnet.url = "github:Programmerino/dotnet-nix";

  inputs.fable.url = "github:Programmerino/fable.nix"; 

  outputs = { self, nixpkgs, flake-utils, fable, dotnet }:
    flake-utils.lib.eachSystem(["x86_64-linux" "aarch64-linux"]) (system:
      let
        pkgs = import nixpkgs { 
          inherit system;
        };
        name = "Helpers";
        version = let _ver = builtins.getEnv "GITVERSION_NUGETVERSIONV2"; in if _ver == "" then "0.0.0" else "${_ver}.${builtins.getEnv "GITVERSION_COMMITSSINCEVERSIONSOURCE"}";
        sdk = pkgs.dotnet-sdk;
        nodejs = pkgs.nodejs-12_x;
        library = true;
        project = "${name}.fsproj";
        useFable = true;

      in rec {
          devShell = pkgs.mkShell {
            inherit name version library;
            inherit useFable;
            DOTNET_CLI_HOME = "/tmp/dotnet_cli";
            DOTNET_CLI_TELEMTRY_OPTOUT=1;
            CLR_OPENSSL_VERSION_OVERRIDE=1.1;
            DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1;
            DONTET_ROOT = "${sdk}";
            buildInputs = defaultPackage.nativeBuildInputs ++ [ pkgs.starship sdk pkgs.git fable.defaultPackage."${system}" ];
            shellHook = ''
              eval "$(starship init bash)"
            '';
          };
    
          defaultPackage = dotnet.buildDotNetProject.${system} rec {
              inherit name version sdk system;
              inherit library useFable project;
              src = ./.;
              lockFile = ./packages.lock.json;
              configFile =./nuget.config;
              fablePackage = fable.defaultPackage."${system}";
              nodePackage = nodejs;
              nugetSha256 = "sha256-KORpWLqiTUw2ntJWt8MD3wFTkZL1/zjjkB7HRLhufYM=";
          };

          packages.nuget = defaultPackage;
          packages.release = defaultPackage;
      }
    );
}