{
    description = "Scientific dev environment with Julia";

    inputs = {
        # set your systems using: https://github.com/nix-systems/nix-systems?tab=readme-ov-file#available-system-flakes
        systems.url = "github:nix-systems/x86_64-linux";

        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        flake-utils = {
            url = "github:numtide/flake-utils";
            inputs.systems.follows = "systems";
        };
        devshell = {
            url = "github:numtide/devshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nima = {
            url = "github:Vortriz/nix-manipulator";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
            inputs.flake-utils.follows = "flake-utils";
            inputs.devshell.follows = "devshell";
        };
    };

    outputs =
        {
            self,
            nixpkgs,
            flake-utils,
            devshell,
            nima,
            ...
        }:
        flake-utils.lib.eachDefaultSystem (
            system:
            let
                inherit (nixpkgs) lib;
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ devshell.overlays.default ];
                };
            in
            {
                formatter = pkgs.treefmt.withConfig {
                    runtimeInputs = [
                        pkgs.nixfmt
                    ];
                    settings = {
                        formatter.nixfmt = {
                            command = "nixfmt";
                            includes = [ "*.nix" ];
                            options = [ "--indent=4" ];
                        };
                    };
                };

                packages = {
                    default =
                        pkgs.julia_111.withPackages.override
                            {
                                augmentedRegistry = pkgs.callPackage ./nix/registry.nix { };
                            }
                            [
                                "Pluto"
                                "PlutoUI"
                                "LanguageServer"
                                "JuliaFormatter"
                                "Comonicon"

                                "ArrayPadding"
                                "CairoMakie"
                                "CircularArrays"
                                "Colors"
                                "ColorSchemes"
                                "CSV"
                                "DataFrames"
                                "Distributions"
                                "EasyFit"
                                # "GLMakie"
                                "GraphPlot"
                                "Graphs"
                                "ImageFiltering"
                                "Karnak"
                                "LaTeXStrings"
                                "OffsetArrays"
                                "OrdinaryDiffEq"
                                "Plots"
                                "PlutoPlotly"
                                "ProgressLogging"
                                "StatsBase"
                            ];
                };

                devShells.default =
                    let
                        juliaEnv = self.packages.${system}.default;
                    in
                    pkgs.devshell.mkShell {
                        name = "pluto-julia";
                        devshell.motd = "";

                        commands = [
                            {
                                name = "pluto";
                                category = "[julia]";
                                help = "Launch Pluto";
                                command = ''
                                    ${juliaEnv}/bin/julia -e "import Pluto; Pluto.run()"
                                '';
                            }
                            {
                                name = "update-registry";
                                category = "[julia]";
                                help = "Update the Julia package registry used in this environment";
                                command = lib.getExe (
                                    pkgs.writers.writePython3Bin "update-registry" {
                                        libraries = [ nima.packages.${system}.default ];
                                    } ./nix/update.py
                                );
                            }
                        ];

                        env = [
                            {
                                name = "JULIA_NUM_THREADS";
                                value = "auto";
                            }
                            {
                                name = "julia";
                                value = "${juliaEnv}/bin/julia";
                            }
                        ];

                        packages = [
                            juliaEnv
                            pkgs.nix-prefetch-git
                            pkgs.ffmpeg
                        ];

                        devshell.startup.default.text =
                            let
                                projectPath = "${self.packages.${system}.default.projectAndDepot.outPath}/project";
                            in
                            ''
                                rm -f Project.toml
                                ln -sf ${projectPath}/Project.toml $PRJ_ROOT/
                                rm -f Manifest.toml
                                ln -sf ${projectPath}/Manifest.toml $PRJ_ROOT/
                            '';
                    };
            }
        );
}
