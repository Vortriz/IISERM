import marimo

__generated_with = "0.13.4"
app = marimo.App(width="medium")


@app.cell
def _(mo):
    mo.md(
        """
    # WS 08 17-03-25

    > Name: Rishi Vora
    > 
    > Roll No: MS21113
    """
    )
    return


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _():
    import re
    import math
    import numpy as np
    return math, np, re


@app.cell
def _(mo):
    mo.md(r"""## RegEx""")
    return


@app.cell
def _(mo):
    mo.md(r"""### Write regular expression to match:""")
    return


@app.cell
def _(mo):
    mo.md(r"""#### a. Date given as `dd-mm-yyyy` or `dd/mm/yyyy` or `dd.mm.yyyy` format.""")
    return


@app.cell
def _(re):
    date = "22/11/2003"
    re.search(r"\d{2}(\/|\-|\.)\d{2}\1\d{4}", date)
    return


@app.cell
def _(mo):
    mo.md(r"""#### b. Email ID (name@domain.rest) [**name** can be alphanumeric, **domain** and **rest** are alphabets]""")
    return


@app.cell
def _(re):
    email = "abc123ef@omedomain.sometld"
    re.search(r"\w+@[a-zA-Z]+\.[a-zA-Z]+", email)
    return


@app.cell
def _(mo):
    mo.md(r"""#### c. Extract this information from the text below: Mr. X date of birth is **02/10/1989** and email id is **test@gmail.com**.""")
    return


@app.cell
def _(re):
    text = "Mr. X date of birth is 02/10/1989 and email id is test@gmail.com."
    m=re.search(r"(\d{2}(\/|\-|\.)\d{2}\2\d{4}).*?(\w+@[a-zA-Z]+\.[a-zA-Z]+)", text)
    m.groups()
    return


@app.cell
def _(mo):
    mo.md(r"""### Rewrite to Homo Sapiens to H. sapiens or any similar names of organisms (general regex)""")
    return


@app.cell
def _(re):
    organism = "Homo sapiens"
    re.sub(r"(\w)\w*\s(\w+)", r"\1. \2", organism)
    return


@app.cell
def _(mo):
    mo.md(
        r"""
    ### Rewrite '>CAA57801.1= GFP [Mus Musculus]' to '>CAA57801_M.Musculus'.
    Note: there could be any number of characters/space between >ID. and '[' symbol
    """
    )
    return


@app.cell
def _(re):
    somestr = ">CAA57801.1= GFP [Mus Musculus]"
    re.sub(r"(>\w+)\..*\[(\w)\w*\s(\w+)\]", r"\1_\2.\3", somestr)
    return


@app.cell
def _(mo):
    mo.md(
        r"""
    ### Rewrite ">NM_001300425.1 Drosophila melanogaster Akt kinase (Akt), transcript variant E, mRNA" as ">NM_001300425_D.melanogaster_Akt_mRNA". Note: the >NM is fixed for any mRNA, the transcript variant may or may not be present i.e. the character after a variant is optional.
    - The general format is '>NM_DIGITS.ONE-TWO_DIGITS TAXON SPECIES LONG-NAME (SHORT_NAME), transcript variant OPTIONAL_TYPE, mRNA
    - LONG-NAME-multiple words, SHORT_NAME-one word OPTIONAL_TYPE-one single word
    """
    )
    return


@app.cell
def _(re):
    someotherstr = ">NM_001300425.1 Drosophila melanogaster Akt kinase (Akt), transcript variant, mRNA"
    re.sub(r"(>NM\w+)\.\d{1,2} (\w)\w* (\w+) .* \((\w+)\), transcript variant( \w)?, mRNA", r"\1_\2.\3_\4_mRNA", someotherstr)
    return


@app.cell
def _(mo):
    mo.md(r"""## Reading PDB file""")
    return


@app.cell
def _(mo):
    mo.md(
        r"""
    ### Write a program to read the content of the PDB file (**atom_cord.pdb.txt**) into the _dict_ data type in the following form:

            ```
            x[RESID][ATOMNAME]=[Xcord,Ycord,Zcord]
            x[RESID]['resname']=RESNAME
            ```

        for instance, using `x[5]['resname']` should return residue name and `x[5][CA]` should return list with coordinates.

        ```
        RESID: 23-26
        RESNAME:18-20
        ATOMNAME:12-16
        Xcord: 31-38
        Ycord: 39-46
        Zcord: 47-54
        ```
    """
    )
    return


@app.function
def parse_pdb_file(file_path):
    pdb_dict = {}

    with open(file_path, 'r') as file:
        for line in file:
            if line.startswith("ATOM") or line.startswith("HETATM"):
                atom_name = line[12:16].strip()
                res_name = line[17:20].strip()
                res_id = int(line[22:26].strip())

                x_coord = float(line[30:38].strip())
                y_coord = float(line[38:46].strip())
                z_coord = float(line[46:54].strip())

                if res_id not in pdb_dict:
                    pdb_dict[res_id] = {'resname': res_name}

                pdb_dict[res_id][atom_name] = [x_coord, y_coord, z_coord]

    return pdb_dict


@app.cell
def _():
    pdb_dict = parse_pdb_file("atom_cord.pdb.txt")
    return (pdb_dict,)


@app.cell
def _(pdb_dict):
    pdb_dict
    return


@app.cell
def _(mo):
    mo.md(r"""### After reading the content, the program should be able to do the following:""")
    return


@app.cell
def _(mo):
    mo.md(r"""#### Find the composition of the residues. (occurrence of amino acids in the PDB file).""")
    return


@app.function
def find_residue_composition(pdb_dict):
    composition = {}

    residue_names = [pdb_dict[res_id]['resname'] for res_id in pdb_dict]
    unique_residue_names = set(residue_names)

    for resname in unique_residue_names:
        composition[resname] = residue_names.count(resname)

    return composition


@app.cell
def _(pdb_dict):
    find_residue_composition(pdb_dict)
    return


@app.cell
def _(mo):
    mo.md(r"""#### Find whether a residue has the same number of atoms. Find the average number of atoms.""")
    return


@app.function
def analyze_atom_count(pdb_dict):
    atom_counts = {}

    for res_id, residue in pdb_dict.items():
        atom_counts[res_id] = len(residue) - 1  # Subtract 1 for 'resname' key

    # Check if all residues have the same number of atoms
    same_atoms = len(set(atom_counts.values())) == 1

    avg_atoms = sum(atom_counts.values()) / len(atom_counts)

    return same_atoms, avg_atoms


@app.cell
def _(pdb_dict):
    same_atoms, avg_atoms = analyze_atom_count(pdb_dict)
    print(f"Same number of atoms in all residues: {same_atoms}")
    print(f"Average number of atoms per residue: {avg_atoms}")
    return


@app.cell
def _(mo):
    mo.md(
        r"""
    #### Find the average distance between two consecutive CA residues using the formula:

    v1=[x1,x2,x3] and v2=[y1,y2,y3]

    vdiff=v2-v1 (vector difference)

    d=sqrt(vdiff.vdiff)
    """
    )
    return


@app.cell
def _(math):
    def calculate_distance(v1, v2):
        vdiff = [v2[i] - v1[i] for i in range(3)]
        squared_sum = sum(diff**2 for diff in vdiff)
        return math.sqrt(squared_sum)
    return (calculate_distance,)


@app.cell
def _(calculate_distance, np):
    def avg_CA_distance(pdb_dict):
        CA_distances = np.array([])

        for resid in list(pdb_dict.keys())[:-1] :
            v1 = pdb_dict[resid]["CA"]
            v2 = pdb_dict[resid+1]["CA"]
            distance = calculate_distance(v1, v2)
            CA_distances = np.append(CA_distances, distance)

        avg_CA_dist = np.average(CA_distances)

        return CA_distances, avg_CA_dist
    return (avg_CA_distance,)


@app.cell
def _(avg_CA_distance, pdb_dict):
    CA_distances, avg_CA_dist = avg_CA_distance(pdb_dict)
    print(avg_CA_dist)
    return


@app.cell
def _(mo):
    mo.md(r"""## Sequence Alignment""")
    return


@app.cell
def _(mo):
    mo.md(r"""### Perform sequence alignment of 'ATGCC' and 'AGC' using Dynamic Programming algorithm. Use Match score of 3, Mismatch score 0, and gap score of -1.""")
    return


@app.cell
def _(np):
    def initialize(rows, cols, scores):
        grid = np.zeros((rows+1, cols+1), dtype=int)
        gap_score = scores["gap"]

        grid[0] = [i*gap_score for i in range(cols+1)]
        grid[:,0] = [i*gap_score for i in range(rows+1)]

        return grid
    return (initialize,)


@app.cell
def _(np):
    def fill(grid, top, left, scores):
        directions = np.full(grid.shape, "", dtype="U3")

        for (row,col),elem in np.ndenumerate(grid):
            if row == 0:
                directions[row, col] = "L"
                continue
            elif col == 0:
                directions[row, col] = "U"
                continue

            S_ij = {
                "D": grid[row-1, col-1] + (scores["match"] if top[col-1] == left[row-1] else scores["mismatch"]),
                "L": grid[row, col-1] + scores["gap"],
                "U": grid[row-1, col] + scores["gap"]
            }
            m = max(S_ij.values())
            grid[row, col] = m

            direction = ""
            for key, value in S_ij.items():
                if value == m:
                    direction += key
            directions[row, col] = direction

        return grid, directions
    return (fill,)


@app.function
def traverse(directions, paths) : 
    new_paths = []

    for path in paths :
        i, j = path[-1]

        if i == 0 and j == 0 :
            return paths

        dir_ij = directions[i, j]

        if 'D' in dir_ij :
            new_paths.append(path[:-1] + [(i,j,'D')] + [(i-1,j-1)])
        if 'U' in dir_ij :
            new_paths.append(path[:-1] + [(i,j,'U')] + [(i-1,j)])
        if 'L' in dir_ij :
            new_paths.append(path[:-1] + [(i,j,'L')] + [(i,j-1)])

    return traverse(directions, new_paths)


@app.function
def candidates(paths, top, left):
    candidates = []

    for path in paths:
        aligned = {
            "top": "",
            "left": ""
        }
        for direction in path[:-1]:
            row, col, direction = direction
            if direction == "D":
                aligned["top"] += top[col-1]
                aligned["left"] += left[row-1]
            elif direction == "L":
                aligned["top"] += top[col-1]
                aligned["left"] += "_"
            elif direction == "U":
                aligned["top"] += "_"
                aligned["left"] += left[row-1]

        aligned["top"] = aligned["top"][::-1]
        aligned["left"] = aligned["left"][::-1]
        candidates.append(aligned)

    return candidates


@app.cell
def _():
    top = "GCATGCG"
    left = "GATTACA"

    scores = {
        "match": 3,
        "mismatch": 0,
        "gap": -1
    }
    return left, scores, top


@app.cell
def _(initialize, left, scores, top):
    grid_init = initialize(len(left), len(top), scores)
    grid_init
    return (grid_init,)


@app.cell
def _(fill, grid_init, left, scores, top):
    grid_fill, directions = fill(grid_init, top, left, scores)
    directions
    return (directions,)


@app.cell
def _(directions, left, top):
    traversal_start = (len(left),len(top))
    obtained_paths = traverse(directions, [[traversal_start]])
    for path in obtained_paths :
        print(path)
    return (obtained_paths,)


@app.cell
def _(left, obtained_paths, top):
    candidates(obtained_paths, top, left)
    return


if __name__ == "__main__":
    app.run()
