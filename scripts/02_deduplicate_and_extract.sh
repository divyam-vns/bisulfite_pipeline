#!/usr/bin/env bash
# Usage: bash 02_deduplicate_and_extract.sh config.yaml
CONFIG=$1
if [ -z "$CONFIG" ]; then echo "Usage: $0 config.yaml"; exit 1; fi

python - <<PY
import yaml, pandas as pd, os, subprocess
cfg=yaml.safe_load(open("$CONFIG"))
proj=cfg['project_dir']
aligndir=os.path.join(proj,"alignments")
methdir=os.path.join(proj,"methylation")
os.makedirs(methdir, exist_ok=True)
samples=pd.read_csv(cfg['samples_table'], sep='\\t')
for idx,row in samples.iterrows():
    samp=row['sample_id']
    # find bismark BAM (paired/unpaired naming)
    # Bismark produces files like sample_bismark_bt2_pe.bam
    for f in os.listdir(aligndir):
        if f.startswith(samp) and f.endswith(".bam"):
            bam=os.path.join(aligndir,f)
            # deduplicate
            dedup = bam.replace(".bam", ".deduplicated.bam")
            cmd1=["deduplicate_bismark","--bam", bam]
            print("Deduplicating:", bam)
            subprocess.run(cmd1)
            # bismark_methylation_extractor
            print("Running methylation extractor on deduplicated BAM")
            outprefix=os.path.join(methdir, samp)
            cmd2=["bismark_methylation_extractor","--gzip","--bedGraph","--cytosine_report","--genome_folder", cfg['bismark_genome_dir'], "-o", methdir, bam.replace(".bam",".deduplicated.bam")]
            subprocess.run(cmd2)
print("Dedup and methylation extraction done. Outputs in", methdir)
PY
