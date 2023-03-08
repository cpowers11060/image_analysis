"""
first argument is the sample id e.g. A1
second argument is the working directory
third argument lists iterations

This script generates histograms for 
every deconvolution iteration.

Then this script generates a summary file
that shows a summary of all the histograms
"""

import imagej
import re
import sys
import os
from collections import defaultdict

wd = os.getcwd() + "raw/"

iteration = []
with open(sys.argv[3], "r") as infile:
    for line in infile:
        line = line.rstrip()
        iteration.append(line)
print("iterations: {}",format(" ".join(iteration)))
print(iteration)

print("Loading FIJI env")
ij=imagej.init('~/Applications/Fiji.app')

#wd = sys.argv[2]
#"~/projects/NB_Forams/8c_fluorescence/2023_2_20_Fluorescence/Before/stacks/raw/"
print(wd)

histo_dict = defaultdict(lambda:[])
for iter in iteration:
    macro = """
            open("{}"); 
            run("8-bit");
            run("Z Project...", "projection=[Maximum]");
            saveAs("tif", "{}");
            getHistogram(values, counts, 256);
            Table.setColumn("Count", counts);
            updateResults();
            Table.save("{}");
            """.format(wd+sys.argv[1]+"_decon_"+iter+"iter.tif", wd+sys.argv[1]+"_decon_"+iter+"_projected.tif", wd+"temp_histo.tsv")
    print(macro)
    ij.py.run_macro(macro)
    with open(wd+"temp_histo.tsv", "r") as infile:
        for line in infile:
            line = line.rstrip()
            listall=re.split("\t", line)
            histo_dict[listall[0]].append(listall[1])

with open(wd+sys.argv[1]+"_decon_histo.tsv", "w") as f:
    for i in histo_dict:
         f.write(str(i))
         f.write("\t{}\n".format("\t".join(histo_dict[i])))

#         f.write("{}\t{}\t{}\n".format(i[0], i[1], histo_dict[i]))
