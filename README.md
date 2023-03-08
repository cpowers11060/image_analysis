# image_analysis
# To set up this image analysis pipeline. Create a foler with the z stacks for every sample where the folder is the sample ID.

# Then, modify the snakemake file so the samples variable is all samples you wish to analyze and that it has the full path for the analysis directory
# The following command may be useful for copying over the images
while read p; do cp 10min/${p}\.*/${p}*R*z* image_analysis/${p}_10min/; done < filenames.tsv
