{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.buildNpmPackage {
          pname = "cspell-lsp";
          version = "1.0.0";
          src = ./.;
          npmDepsHash = "sha256-Xbu8/hxUiYKdHYCff649j4i4gW0cpDvDZA2f6L3iFuI=";

          nativeBuildInputs = with pkgs; [
            bun
          ];

          buildPhase = ''
            bun build ./src/main.ts --outfile=dist/cspell-lsp.js --target=node
          '';

          installPhase = ''
            mkdir -p $out/bin
            sed -i "1s|^#!.*$|#!${pkgs.nodejs}/bin/node|" dist/cspell-lsp.js
            install -D -m755 dist/cspell-lsp.js $out/bin/cspell-lsp
          '';
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            bun
          ];
        };
      }
    );
}
