"""
This script will take a file specifying 
Several images to deconvolve and will 
deconvolve them using deconvolutionlab.
The second path should be the psf image
The third location should be the output path
"""

import imagej
import re
import sys

print("Loading FIJI env")
ij=imagej.init('~/Applications/Fiji.app')

#print("determining image stack paths")
#paths = []
#with open(sys.argv[1], "r") as infile:
#    for line in infile:
#        line = line.rstrip()
#        paths.append(line)

macro = """ open("{}")""".format(sys.argv[3]+sys.argv[1])
ij.py.run_macro(macro)

deconvolve = [1]

print("deconvolving")
#for i in paths:
#for j in deconvolve:
print("iteration {}".format(1))
macro="""run("DeconvolutionLab2 Run", "-image directory '{}' pattern .tif -psf file '{}' -algorithm RL {} -path '{}' -out stack '{}' noshow -monitor no");""".format(sys.argv[3]+sys.argv[1], sys.argv[3]+sys.argv[2], 1, sys.argv[3],"{}_decon.tif".format(sys.argv[1]))
print(macro)
ij.py.run_macro(macro)
