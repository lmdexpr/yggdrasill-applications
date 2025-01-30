{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    opam-nix.url = "github:tweag/opam-nix";
  };
  outputs = { nixpkgs, flake-utils, opam-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on   = opam-nix.lib.${system};

        package = "ratatoskr";

        src = ./.;
        localNames = with builtins;
          let
            files      = attrNames (readDir src);
            opam_files = map (match "(.*)\.opam$") files;
            non_nulls  = filter (f: !isNull f);
          in 
            map (f: elemAt f 0) (non_nulls opam_files);

        localPackagesQuery = with builtins; 
          listToAttrs (map (p: { name = p; value = "*"; }) localNames);

        devPackagesQuery = {
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          utop = "*";
        };

        query = devPackagesQuery // localPackagesQuery;

        localPackages =
          on.buildDuneProject
          {
            inherit pkgs;
            resolveArgs = { with-test = false; with-doc = false; };
            pinDepends = true;
          }
          package
          src
          query;

        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) localPackages);
      in
      {
        legacyPackages = pkgs;
        packages = {
          default = localPackages.ratatoskr;
        };

        devShells.default =
          pkgs.mkShell {
            inputsFrom  = builtins.map (p: localPackages.${p}) localNames;
            buildInputs = devPackages ++ (with pkgs; [ nil nixpkgs-fmt ]);
          };
      });
}
