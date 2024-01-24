"""
Opens an image stack and saves it as a z stack tif

Takes sample ID as standard in 1 and the working directory as standard in 2
"""

import imagej
import re
import sys
import os
from collections import defaultdict

wd = os.getcwd() + "/raw/"
print("Loading FIJI env")
ij=imagej.init("/mnt/c/Users/YZLab/Documents/fiji-linux64/Fiji.app")

#wd = sys.argv[2]
print(wd)

macro = """
        File.openSequence("{}/");
        saveAs("Tiff", "{}");
        """.format(wd+sys.argv[1]+"/", wd+sys.argv[1]+".tif")
print(macro)
ij.py.run_macro(macro)
