# IDC402 - Nonlinear dynamics, chaos and complex systems

## Term Paper

One grading component was writing a term paper. I wrote about **Delay embedding of Rossler system**. You can find the paper [here](term-paper/term-paper.pdf).

The code for it in stored in the `term-paper` folder.

## Instructions to run the codes

Either clone the entire repository:

```
git clone https://github.com/Vortriz/IISERM
```

or download this subfolder by providing `https://github.com/Vortriz/IISERM/tree/main/IDC402` to [download-directory](https://download-directory.github.io) or [DownGit](https://downgit.github.io/#/home).

### Dependencies

If you use Nix, then simply run `nix develop` to drop into a shell with all dependencies. Else, install the following:

- [`julia`](https://julialang.org/install)

After that, install [Pluto.jl](https://plutojl.org/#install).

### Running the codes

Launch a Pluto session in Julia REPL:

```
julia> import Pluto; Pluto.run()
```

and run the desired notebook.
