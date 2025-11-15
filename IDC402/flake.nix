{
  description = "Environment for IDC402";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    formatter.${system} = pkgs.alejandra;

    devShells.${system}.default = pkgs.mkShell {
      name = "IDC402";

      packages = with pkgs; [
        (julia.withPackages ["Plots" "Pluto" "LanguageServer"])
        typst
      ];

      env = {
        TYPST_FONT_PATHS = ".";
      };
    };
  };
}
