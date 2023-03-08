"""
This script will calculate the rate
of change for the global image estimate.
"""

from collections import defaultdict
import re
import sys

# calculate the sum of intensity for each image
global_sum = []
deriv = defaultdict(lambda:[])
length = 0
with open(sys.argv[1], "r") as infile:
    for line in infile:
        line = line.rstrip()
        listall = re.split("\t", line)
        global_sum = [0] * len(listall[1:])
        length_list = len(listall[1:])
with open(sys.argv[1], "r") as infile:
    for line in infile:
        line = line.rstrip()
        listall=re.split("\t", line)
        i = 1
        while i < len(listall):
            if listall[0] != ' ':
                global_sum[i-1] += float(listall[i])
            i+=1

#goes back through the file and calculates the difference of each point
with open(sys.argv[1], "r") as infile:
    for line in infile:
        line = line.rstrip()
        listall=re.split("\t", line)
        i = 2
        deriv[listall[0]] = [0]*length_list
        while i < len(listall):  
            if i > 1 and listall[0] != " ":
                deriv[listall[0]][i-1] = abs((float(listall[i])/global_sum[i-1]) - (float(listall[i-1])/global_sum[i-2]))
            i+=1
print(deriv)
# calculate the sum of the difference
global_diff = []
length = 0
for i in deriv:
    global_diff = [0] * len(deriv[i])
for i in deriv:
    j = 1 
    while j < len(deriv[i]):
        global_diff[j]+=deriv[i][j]
        j+=1

print(global_diff)
prev = ''
global_deriv = []
global_diff = global_diff[1:]
for i in global_diff:
    if prev == '':
        prev = i
    else:
        global_deriv.append(str(i - prev))
        prev = i

print(global_deriv)

count_1 = 1
count_2 = 2
with open(sys.argv[1]+"_deriv.tsv", "w") as f:
    f.write("iteration\tGn\n")
    for i in global_deriv:
        f.write("{}-{}\t{}\n".format(count_2, count_1, i))
        count_1+=1
        count_2+=1

    
