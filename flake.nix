{
  description = "Ressources pédagogiques mpi-informatique/enseignement";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      packagesFor = system: import nixpkgs { inherit system; };
      manifest = (builtins.fromTOML (builtins.readFile ./typst.toml)).package;
      source = nixpkgs.lib.cleanSourceWith {
        src = self;
        filter = path: type:
          let name = builtins.baseNameOf path; in
          !(builtins.elem name [ ".git" ".direnv" "build" "tmp" "__pycache__" "node_modules" ".DS_Store" ])
          && !(nixpkgs.lib.hasSuffix ".log" name);
      };
      dependencies = builtins.fromJSON (builtins.readFile ./nix/typst-packages.json);
    in {
      packages = forAllSystems (system:
        let
          pkgs = packagesFor system;
          package = pkgs.runCommand "enseignement-typst-${manifest.version}" {
            nativeBuildInputs = [ pkgs.python3 ];
          } ''
            python3 ${source}/scripts/package.py --path "$out"
          '';
          previews = map (dependency: {
            name = "preview/${dependency.name}/${dependency.version}";
            path = pkgs.fetchzip {
              url = "https://packages.typst.org/preview/${dependency.name}-${dependency.version}.tar.gz";
              hash = dependency.hash;
              stripRoot = false;
            };
          }) dependencies;
        in {
          default = package;
          typst-package = package;
          typst-packages = pkgs.linkFarm "enseignement-typst-packages" (previews ++ [{
            name = "mpi-informatique/enseignement/${manifest.version}";
            path = "${package}/mpi-informatique/enseignement/${manifest.version}";
          }]);
        });
      devShells = forAllSystems (system:
        let pkgs = packagesFor system; in {
          default = pkgs.mkShellNoCC {
            packages = [ pkgs.typst pkgs.just pkgs.python3 pkgs.ocaml pkgs.ripgrep ];
            TYPST_PACKAGE_PATH = self.packages.${system}.typst-packages;
          };
        });
      checks = forAllSystems (system:
        let pkgs = packagesFor system; in {
          documents = pkgs.runCommand "enseignement-check" {
            nativeBuildInputs = [ pkgs.typst pkgs.just pkgs.python3 pkgs.ocaml ];
            TYPST_PACKAGE_PATH = self.packages.${system}.typst-packages;
          } ''
            export HOME="$TMPDIR"
            cp -R ${source} source
            chmod -R u+w source
            cd source
            just check
            mkdir -p "$out"
            cp -R build/. "$out/"
          '';
        });
    };
}
