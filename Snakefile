sample = ["A1_10min", "A2_10min", "A3_10min", "A1_20min", "A2_20min", "A3_20min", "A1_30min", "A2_30min", "A3_30min",
          "A4_10min", "A5_10min", "A6_10min", "A4_20min", "A5_20min", "A6_20min", "A4_30min", "A5_30min", "A6_30min",]

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

