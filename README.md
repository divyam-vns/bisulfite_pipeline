# Bisulfite Sequencing Pipeline (Bismark + methylKit/DSS)

**Purpose:** End-to-end pipeline for bisulfite sequencing (WGBS/RRBS/amplicon) analysis:
- QC & adapter trimming (Trim Galore!)
- Align to bisulfite-converted genome (Bismark)
- Deduplication & methylation extraction (Bismark)
- QC reports (bismark2report, MultiQC)
- Differential methylation analysis (methylKit; optional DSS)
- Summary plotting (R)

## Quickstart
1. Edit `config.yaml` and `samples.tsv`.
2. Create conda environment:

conda env create -f environment.yml
conda activate bsseq_env

3. Run pipeline:
bash scripts/00_trim_galore.sh config.yaml
bash scripts/01_bismark_align.sh config.yaml
bash scripts/02_deduplicate_and_extract.sh config.yaml
bash scripts/03_generate_reports.sh config.yaml
Rscript scripts/04_dmr_analysis_methylkit.R config.yaml
Rscript scripts/05_summary_plots.R config.yaml


## Notes
- Build Bismark genome index beforehand (`bismark_genome_preparation /path/to/genome/`).
- For RRBS, Trim Galore is run with `--rrbs`.
- Recommended ≥ 3 biological replicates per condition for DMR calling.

## Outputs
- `alignments/` (BAMs), `methylation/` (CpG reports, bedGraph), `reports/` (bismark2report & MultiQC), `results/` (DMC/DMR tables, plots).
