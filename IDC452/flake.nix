{
  description = "Environment for IDC452";

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
      name = "IDC452";

      packages = with pkgs; [
        typst
      ];

      env = {
        TYPST_FONT_PATHS = ".";
      };
    };
  };
}
