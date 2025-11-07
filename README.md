# Bisulfite Sequencing Pipeline (Bismark + methylKit/DSS)

**Purpose:** End-to-end pipeline for bisulfite sequencing (WGBS/RRBS/amplicon) analysis:
- QC & adapter trimming (Trim Galore!)
- Align to bisulfite-converted genome (Bismark)
- Deduplication & methylation extraction (Bismark)
- QC reports (bismark2report, MultiQC)
- Differential methylation analysis (methylKit; optional DSS)
- Summary plotting (R)

## Quickstart

1. Edit `config.yaml` and `samples.tsv`. Edit config.yaml and samples.tsv to reflect your system paths and sample filenames.
2. Prepare Bismark genome:
   
   ```bismark_genome_preparation /path/to/bismark_genome```

4. Create environment and activate:

   ```conda env create -f environment.yml```
   
    ```conda activate bsseq_env```

6. Run steps sequentially:
   
     ```bash scripts/00_trim_galore.sh config.yaml```
   
    ```bash scripts/01_bismark_align.sh config.yaml```
  
    ```bash scripts/02_deduplicate_and_extract.sh config.yaml```
  
    ```bash scripts/03_generate_reports.sh config.yaml```
  
    ```Rscript scripts/04_dmr_analysis_methylkit.R config.yaml```
  
    ```Rscript scripts/05_summary_plots.R config.yaml```


## Notes
- For RRBS, set is_rrbs: true in config.yaml (Trim Galore handles MspI cut sites).
- Validate bisulfite conversion rate using spike-in controls (lambda phage) or non-CpG contexts.
- For low coverage WGBS, prefer DMR tools that model dispersion (DSS, bsseq) over simple per-CpG tests.
- Use multiqc to aggregate FastQC and Bismark reports (scripts/03_generate_reports.sh handles it).
- For visualization in genome browsers, use the --bedGraph output from bismark_methylation_extractor and convert to bigWig.
- Build Bismark genome index beforehand (`bismark_genome_preparation /path/to/genome/`).
- For RRBS, Trim Galore is run with `--rrbs`.
- Recommended ≥ 3 biological replicates per condition for DMR calling.

## Outputs
- `alignments/` (BAMs), `methylation/` (CpG reports, bedGraph), `reports/` (bismark2report & MultiQC), `results/` (DMC/DMR tables, plots).
