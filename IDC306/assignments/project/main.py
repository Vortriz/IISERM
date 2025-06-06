import marimo

__generated_with = "0.13.4"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell
def _(mo):
    mo.md(
        r"""
    # IDC306 - Project

    > Name: Rishi Vora
    > 
    > Roll No: MS21113
    >
    > Group: 4
    """
    )
    return


@app.cell
def _():
    import numpy as np
    return (np,)


@app.class_definition
class PDBReader:
    def __init__(self, filename):
        self.file = self.readFile(filename)
        self.hetero_data = self._get_data("HETATM")
        self.atom_data = self._get_data("ATOM")

    def readFile(self, filename):
        """Returns the contents of the PDB file"""
        try :
            with open(filename, 'r') as f:
                contents = f.read().splitlines()
        except FileNotFoundError:
            print("The file with given name does not exist!")
            
        return contents

    def _get_data(self, type):
        """Internal function to get ATOM and HETATM records"""
        return list(filter(lambda l: l.startswith(type), self.file))

    def hetero(self):
        """Returns number of HETATM records"""
        return len(self.hetero_data)

    def heteroNames(self):
        """Returns list of residue names of HETATM records"""
        res_names = list(map(lambda l: l[17:20].strip(), self.hetero_data))
        if len(res_names) == 0: raise Exception("No HETATM records")
            
        return res_names

    def heteroInfo(self, name):
        """Returns number of HETATM records for a given residue name"""
        het_name_list = self.heteroNames()
        het_data = {name: het_name_list.count(name) for name in set(het_name_list)}

        if het_data[name] == 0: raise Exception("No HETATM records for the given residue name")
        
        return het_data[name]

    def heteroCord(self, name):
        """Returns coordinates of all HETATM record given a residue name"""
        pdb_dict = {}
        
        for line in self.hetero_data:
            if line[17:20].strip() == name:
                atom_name = line[12:16].strip()
    
                x_coord = float(line[30:38].strip())
                y_coord = float(line[38:46].strip())
                z_coord = float(line[46:54].strip())
    
                pdb_dict[atom_name] = [x_coord, y_coord, z_coord]

        if len(pdb_dict) == 0: raise Exception("No HETATM record the given residue name")
            
        return pdb_dict

    def atomCord(self, i):
        """Returns coordinates of all ATOM records given a residue number"""
        pdb_dict = {}
        
        for line in self.atom_data:
            if int(line[23:26].strip()) == i:
                atom_name = line[12:16].strip()
    
                x_coord = float(line[30:38].strip())
                y_coord = float(line[38:46].strip())
                z_coord = float(line[46:54].strip())
    
                pdb_dict[atom_name] = [x_coord, y_coord, z_coord]
                
        if len(pdb_dict) == 0: raise Exception("No ATOM record the given residue number")
            
        return pdb_dict


@app.cell
def _():
    pdb = PDBReader("project/proj4.pdb")
    return (pdb,)


@app.cell
def _(mo):
    mo.md(r"""## Part a""")
    return


@app.cell
def _(pdb):
    pdb.hetero()
    return


@app.cell
def _(mo):
    mo.md(r"""## Part b""")
    return


@app.cell
def _(pdb):
    pdb.heteroNames()
    return


@app.cell
def _(mo):
    mo.md(r"""## Part c""")
    return


@app.cell
def _(pdb):
    pdb.heteroInfo("GDP")
    return


@app.cell
def _(mo):
    mo.md(r"""## Part d""")
    return


@app.cell
def _(pdb):
    pdb.atomCord(10)
    return


@app.cell
def _(mo):
    mo.md(r"""## Part e""")
    return


@app.cell
def _(pdb):
    pdb.heteroCord("GDP")
    return


@app.cell
def _(mo):
    mo.md(r"""## Finding surrounding atoms""")
    return


@app.cell
def _(np):
    def surrounding(filename):
        def distance(v1, v2):
            return np.linalg.norm(v1 - v2)
    
        pdb = PDBReader(filename)

        atom_min_res = min(map(lambda l: int(l[23:26].strip()), pdb.atom_data))
        atom_max_res = max(map(lambda l: int(l[23:26].strip()), pdb.atom_data))

        atom_structured_data = {}
        for i in range(atom_min_res, atom_max_res+1):
            atom_structured_data[i] = pdb.atomCord(i)

        nearby_residues = []
        for het_atm_coords in pdb.heteroCord(max(pdb.heteroNames())).values():
            for atom_res_id in atom_structured_data.keys():
                for atom_coord in atom_structured_data[atom_res_id].values():
                    if distance(np.array(het_atm_coords), np.array(atom_coord)) < 5:
                        nearby_residues.append(atom_res_id)
                        break

        return nearby_residues
    return (surrounding,)


@app.cell
def _(surrounding):
    surrounding("project/proj4.pdb")
    return


if __name__ == "__main__":
    app.run()
