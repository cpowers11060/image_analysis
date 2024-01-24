sample = ["Dark_A1",
"Dark_A10",
"Dark_A3",
"Dark_A4",
"Dark_A5",
"Dark_A6",
"Dark_A7",
"Dark_A8",
"Dark_A9",
"Dark_C2",
"Dark_C3",
"Dark_C4",
"Dark_C5",
"Dark_C7",
"Dark_C8",
"Dark_E1",
"Dark_E2",
"Dark_E3",
"Dark_E4",
"Dark_E5",
"Dark_E6",
"Dark_E7",
"Dark_E8",
"Dark_E9",
"Dark_G1",
"Dark_G10",
"Dark_G7",
"Dark_G8",
"Light_A1",
"Light_A10",
"Light_A5",
"Light_A6",
"Light_A8",
"Light_A9",
"Light_C1",
"Light_C10",
"Light_C5",
"Light_C7",
"Light_C9",
"Light_E1",
"Light_E2",
"Light_E3",
"Light_E5",
"Light_E6",
"Light_E7",
"Light_E8",
"Light_G1",
"Light_G10",
"Light_G2",
"Light_G3",
"Light_G4",
"Light_G5",
"Light_G6",
"Light_G7",
"Light_G8",
"Light_G9"]


rule all:
    input:
        #"raw/A5_decon_histo.tsv"
        expand("raw/{ID}.tif_raw_avg.tsv", ID=sample),
        "table_avg_intensity.tsv"

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
        "raw/{ID}.tif_raw_avg.tsv"
    shell:
        """
        python scripts/avg_int.py {wildcards.ID}.tif 
        """

rule combine_avg_intensity:
    input:
        expand("raw/{ID}.tif_raw_avg.tsv", ID = sample)
    output:
        "table_avg_intensity.tsv"
    shell:
        "python scripts/combine_raw_avg.py raw/*_raw_avg.tsv > table_avg_intensity.tsv"

