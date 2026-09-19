{
  description = "A custom Helix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      wrappers = {
        url = "github:nix-community/nix-wrapper-modules";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = { nixpkgs, wrappers, ... }:
    let
      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f:
        lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));

      yaziPicker = yaziArgs: [
        ":sh rm -f /tmp/unique-file"
        ":insert-output yazi ${yaziArgs}--chooser-file=/tmp/unique-file"
        ":insert-output echo \"\\x1b[?2004h\" > /dev/tty"
        ":open %sh{cat /tmp/unique-file}"
        ":redraw"
      ];

      mkHelix =
        {
          pkgs,
          enableYaziIntegration ? false,
        }:
        wrappers.wrappers.helix.wrap {
          inherit pkgs;

          settings = lib.mkMerge [
            {
              theme = "catppuccin_mocha";
              editor.line-number = "relative";
              editor.cursor-shape = {
                normal = "block";
                insert = "bar";
                select = "underline";
              };
              keys.normal = {
                "C-s" = ":w";
                "C-q" = ":bc";
              };
            }

            (lib.mkIf enableYaziIntegration {
              keys.normal.space = {
                e = yaziPicker "";
                E = yaziPicker "%{buffer_name} ";
              };
            })
          ];

          runtimePkgs = [ pkgs.nixd ];

          filesToExclude = [ "share/applications/*.desktop" ];
        };
    in
    {
      packages = forAllSystems (pkgs: rec {
        helix = lib.makeOverridable mkHelix { inherit pkgs; };
        default = helix;
      });
    };
}
