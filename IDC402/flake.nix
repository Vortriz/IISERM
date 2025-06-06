{
    description = "Julia Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = {
        nixpkgs,
        ...
    }: let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
    in {

        devShells.${system} = let
            mkScript = name: text: let
                script = pkgs.writers.writeFishBin name text;
            in
                script;

            scripts = [
                (mkScript "xw" ''xwayland-satellite'')
            ];
        in {
            default = pkgs.mkShell {
                packages =
                with pkgs;
                [
                    xwayland-satellite
                ]
                ++ scripts;

                env =
                    {
                        DISPLAY = ":0";
                        LD_LIBRARY_PATH = ":/run/opengl-driver/lib:/run/opengl-driver-32/lib";
                    };

                shellHook = ''
                    echo "Run xwayland-satellite for GL/WGLMakie"
                '';
            };
        };
    };
}
