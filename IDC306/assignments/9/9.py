import marimo

__generated_with = "0.13.4"
app = marimo.App(width="medium")


@app.cell
def _(mo):
    mo.md(
        r"""
    # WS 09 25-03-25

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
    import numpy as np
    return (np,)


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
    pdb_dict = parse_pdb_file("assignments/atom_cord.pdb.txt")
    return (pdb_dict,)


@app.cell
def _(pdb_dict):
    pdb_dict
    return


@app.cell
def _(mo):
    mo.md(r"""## For the PDB file, calculate angle N-CA-C for all residues and find average angle.""")
    return


@app.cell
def _(np):
    def calculate_angle(v1, v2, v3):
        v1 = np.array(v1)
        v2 = np.array(v2)
        v3 = np.array(v3)

        v1 = v1 - v2
        v3 = v3 - v2

        dot_product = np.dot(v1, v3)
        norm_v1 = np.linalg.norm(v1)
        norm_v3 = np.linalg.norm(v3)

        angle = np.arccos(dot_product / (norm_v1 * norm_v3))
        return np.degrees(angle)
    return (calculate_angle,)


@app.cell
def _(calculate_angle, np):
    def avg_N_CA_C_angle(pdb_dict):
        angles = np.array([])

        for resid in pdb_dict.keys() :
            N = pdb_dict[resid]["N"]
            CA = pdb_dict[resid]["CA"]
            C = pdb_dict[resid]["C"]

            N_CA_C_angle = calculate_angle(N, CA, C)
            angles = np.append(angles, N_CA_C_angle)

        avg_angle = np.average(angles)

        return angles, avg_angle
    return (avg_N_CA_C_angle,)


@app.cell
def _(avg_N_CA_C_angle, pdb_dict):
    N_CA_C_angles, avg_N_CA_C = avg_N_CA_C_angle(pdb_dict)
    print(avg_N_CA_C)
    return


@app.cell
def _(mo):
    mo.md(r"""## Calculate (phi,psi) torsion angles C(i-1)-N(i)-CA(i)-C(i) and N(i)-CA(i)-C(i)-N(i+1).""")
    return


@app.cell
def _(np):
    def calculate_torsion_angle(v1, v2, v3, v4):
        v1 = np.array(v1)
        v2 = np.array(v2)
        v3 = np.array(v3)
        v4 = np.array(v4)

        v1 = v2 - v1
        v2 = v3 - v2
        v4 = v4 - v3

        v1 = v1 / np.linalg.norm(v1)
        v4 = v4 / np.linalg.norm(v4)
        v2 = v2 / np.linalg.norm(v2)

        n1 = np.cross(v1, v2)
        n2 = np.cross(v2, v4)

        m1 = np.cross(n1, n2)

        angle = np.arccos(np.dot(n1, n2) / (np.linalg.norm(n1) * np.linalg.norm(n2)))
        sign = np.dot(m1, v2)

        if sign < 0:
            angle = -angle

        return np.degrees(angle)
    return (calculate_torsion_angle,)


@app.cell
def _(calculate_torsion_angle, np):
    def phi_angle(pdb_dict):
        angles = np.array([])

        for resid in list(pdb_dict.keys())[1:] :
            C_1 = pdb_dict[resid-1]["C"]
            N = pdb_dict[resid]["N"]
            CA = pdb_dict[resid]["CA"]
            C_2 = pdb_dict[resid]["C"]

            phi = calculate_torsion_angle(C_1, N, CA, C_2)
            angles = np.append(angles, phi)

        return angles
    return (phi_angle,)


@app.cell
def _(pdb_dict, phi_angle):
    phi_angle(pdb_dict)
    return


@app.cell
def _(calculate_torsion_angle, np):
    def psi_angle(pdb_dict):
        angles = np.array([])

        for resid in list(pdb_dict.keys())[:-1] :
            N_1 = pdb_dict[resid]["N"]
            CA = pdb_dict[resid+1]["CA"]
            C = pdb_dict[resid+1]["C"]
            N_2 = pdb_dict[resid+1]["N"]

            psi = calculate_torsion_angle(N_1, CA, C, N_2)
            angles = np.append(angles, psi)

        return angles
    return (psi_angle,)


@app.cell
def _(pdb_dict, psi_angle):
    psi_angle(pdb_dict)
    return


if __name__ == "__main__":
    app.run()
