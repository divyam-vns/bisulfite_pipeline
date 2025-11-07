#!/usr/bin/env Rscript
# Usage: Rscript scripts/05_summary_plots.R config.yaml
args <- commandArgs(trailingOnly=TRUE)
if(length(args)<1) stop("Usage: Rscript scripts/05_summary_plots.R config.yaml")
cfg <- yaml::yaml.load_file(args[1])
library(tidyverse); library(pheatmap); library(methylKit)

proj <- cfg$project_dir
outdir <- file.path(proj,"results")
dmc_file <- file.path(outdir,"DMCs_methylKit.tsv")
if(!file.exists(dmc_file)){ stop("DMC file not found; run 04_dmr_analysis_methylkit.R first") }
dmc <- read_tsv(dmc_file)
# Basic volcano-like plot: percent difference vs -log10(qvalue)
dmc <- dmc %>% mutate(logq = -log10(qvalue))
p1 <- ggplot(dmc, aes(x=difference, y=logq)) + geom_point(alpha=0.4) + theme_bw() +
  xlab("Methylation difference (%)") + ylab("-log10(qvalue)") +
  ggtitle("DMCs: methylation difference vs significance")
ggsave(file.path(outdir,"DMC_diff_vs_q.pdf"), p1, width=6, height=5)

# Heatmap of top DMCs across samples (requires methylKit methylation matrix)
# load methylKit unite file (if saved)
# Quick check: distribution of methylation levels per sample
# Attempt to load methylKit object
# If available, generate boxplots
cat("Summary plots saved in", outdir, "\n")
