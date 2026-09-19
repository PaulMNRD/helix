# Helix Config

My [Helix](https://helix-editor.com) configuration, packaged as a standalone Nix package with [nix-wrapper-modules](https://github.com/nix-community/nix-wrapper-modules).

## How it works

The configuration is baked into the package: no Home Manager or NixOS module needed. 

- `enableYaziIntegration` (default `false`): Replaces the default `Space e` / `Space E` file explorers with yazi. It does not install yazi.

```nix
{
  # flake.nix
  inputs.helix.url = "github:PaulMNRD/helix";

  # NixOS configuration
  environment.systemPackages = [
    (inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      enableYaziIntegration = true;
    })
  ];
}
```

Try it without installing: `nix run github:PaulMNRD/helix`
