sample = ["A1", "A2", "A3"]

rule all:
    input:
        "raw/A5_decon_histo.tsv"
        #expand("{id}_decon_histo.tsv", id=sample)

rule redlionfish:
    output:
        "scripts/RedLionfish/redlionfish.py"
    shell:
        """
        cd scripts
        git clone https://github.com/rosalindfranklininstitute/RedLionfish.git
        """

rule genstack:
    output:
        "raw/{ID}.tif"
    shell:
        "python scripts/genstack.py {wildcards.ID}"

# This rule runs the Richardson Lucy deconvolution
# method using the redlionfish python package
rule RL_decon:
    input: 
        "raw/{ID}.tif",
        "scripts/RedLionfish/redlionfish.py"
    output: 
        done = touch("{ID}_deconvoluted.done")
    shell:
        """
        while read p; do python scripts/RedLionfish/redlionfish.py -o ./raw/{wildcards.ID}_decon_${{p}}iter.tif {input} psf/PSF.tif ${{p}}; done < iter.tsv
        """

# This script generates a maximum project z stack 
# image for each of the deconvoluted images created
# above and sumarizes them into a histogram.
rule histogram:
    input:
        "{ID}_deconvoluted.done"
    output:
        "raw/{ID}_decon_histo.tsv"
    shell:
        """
        python scripts/z_project.py {wildcards.ID} iter.tsv 
        python scripts/derive_intChange.py raw/{wildcards.ID}_decon_histo.tsv
        """

# This script takes the raw image file, sets a threshold
# to limit the analysis to the foram cell, and then
# calculates the average intensity
rule avg_intensity:
    input:
        "raw/{ID}.tif"
    output:
        "raw/{ID}_raw_avg.tsv"
    shell:
        """
        python scripts/avg_int.py {input} ~/projects/NB_Forams/8c_fluorescence/2023_2_20_Fluorescence/Before/stacks/raw/
        """
