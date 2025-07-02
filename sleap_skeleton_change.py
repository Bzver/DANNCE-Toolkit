import numpy as np
import h5py

############   W   ############   I   ############   P   ############

def modify_sleap_skeleton(sleap_file, skeleton_new=None):
    with h5py.File(sleap_file, "r") as hdf_file:
        print(hdf_file.keys())
        print((np.shape(hdf_file["frames"])))
        print((np.shape(hdf_file["points"])))

        for i in range(376,376+55):
             for k in range(11):
                print(hdf_file["frames"][i],":",hdf_file["points"][k])

if __name__ == "__main__":
    sleap_file = "D:/Project/Sleap-Models/BTR/labels.NS2000.slp"
    modify_sleap_skeleton(sleap_file)