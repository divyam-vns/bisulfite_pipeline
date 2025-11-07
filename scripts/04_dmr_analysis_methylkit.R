#!/usr/bin/env Rscript
# Usage: Rscript scripts/04_dmr_analysis_methylkit.R config.yaml
args <- commandArgs(trailingOnly=TRUE)
if(length(args)<1) stop("Usage: Rscript 04_dmr_analysis_methylkit.R config.yaml")
cfg <- yaml::yaml.load_file(args[1])
library(methylKit); library(tidyverse)

proj <- cfg$project_dir
methdir <- file.path(proj,"methylation")
samples <- read_tsv(cfg$samples_table, col_types = cols())
# Build file list of CpG reports produced by bismark: sample.CpG_report.txt.gz pattern
files <- file.path(methdir, paste0(samples$sample_id, ".bismark.cov.gz"))
# If extension differs, adapt files vector
# Define treatment vector (0 control, 1 treated)
treatment <- ifelse(samples$condition == unique(samples$condition)[1], 0, 1)

myobj <- methRead(location=files, sample.id=samples$sample_id, assembly="hg38", treatment=treatment, context="CpG")
# Filtering by coverage
filtered <- filterByCoverage(myobj, lo.count=cfg$min_coverage, hi.perc=99.9)
meth <- unite(filtered, destrand=FALSE)
# Differential methylation
diffMeth <- calculateDiffMeth(meth)
# get DMCs with cutoff
sigDMC <- getMethylDiff(diffMeth, difference=25, qvalue=cfg$qvalue_threshold)
# write
outdir <- file.path(proj,"results")
dir.create(outdir, showWarnings=FALSE)
write_tsv(sigDMC, file.path(outdir,"DMCs_methylKit.tsv"))
# Call DMRs (region-based)
dmrRegions <- regionCounts(meth, win.size=cfg$dmr_min_len, step.size=cfg$dmr_min_len)
# Use sliding window approach: call DMRs by applying difference thresholds on aggregated windows (simple approach)
# Save session info
writeLines(capture.output(sessionInfo()), file.path(outdir,"sessionInfo_methylKit.txt"))
cat("methylKit analysis done. Results in", outdir, "\n")

## Note: regionCounts usage may need parameter tuning; alternatively use dmrByCluster or DMRcaller. For publication-grade DMRs, consider DSS::callDMR which models dispersion.
