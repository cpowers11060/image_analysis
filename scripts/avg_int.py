"""
first argument is the sample id e.g. A1
second argument is the working directory
third argument lists iterations
"""

import imagej
import re
import sys
import os
from collections import defaultdict

wd = os.getcwd() + "/raw/"

print("Loading FIJI env")
ij=imagej.init("/mnt/c/Users/YZLab/Downloads/fiji-win64/Fiji.app")

histo_dict = defaultdict(lambda:[])
macro = """
        open("{}"); 
        run("8-bit");
        run("Z Project...", "projection=[Maximum]");
        saveAs("tif", "{}");
        setThreshold(10, 255, "raw");
        run("Measure");
        updateResults();
        Table.save("{}");
        """.format(wd+sys.argv[1], wd+sys.argv[1]+"_projected.tif", wd+sys.argv[1]+"_raw_avg.tsv")
print(macro)
ij.py.run_macro(macro)
