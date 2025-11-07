#!/usr/bin/env bash
# Usage: bash 01_bismark_align.sh config.yaml
CONFIG=$1
if [ -z "$CONFIG" ]; then echo "Usage: $0 config.yaml"; exit 1; fi

python - <<PY
import yaml, pandas as pd, os, subprocess
cfg=yaml.safe_load(open("$CONFIG"))
proj=cfg['project_dir']; threads=str(cfg['threads'])
trimdir=os.path.join(proj,"trimmed")
outdir=os.path.join(proj,"alignments")
os.makedirs(outdir, exist_ok=True)
samples=pd.read_csv(cfg['samples_table'], sep='\\t')
for idx,row in samples.iterrows():
    base=row['sample_id']
    r1=os.path.join(trimdir, os.path.basename(row['r1']).replace('.fastq.gz','_val_1.fq.gz'))
    r2=os.path.join(trimdir, os.path.basename(row['r2']).replace('.fastq.gz','_val_2.fq.gz')) if not pd.isna(row['r2']) else None
    if r2 and os.path.exists(r2):
        cmd=["bismark","--genome", cfg['bismark_genome_dir'], "-1", r1, "-2", r2, "-p", threads, "-o", outdir]
    else:
        cmd=["bismark","--genome", cfg['bismark_genome_dir'], r1, "-p", threads, "-o", outdir]
    print("Running:", " ".join(cmd))
    subprocess.run(cmd)
print("Bismark alignment done. BAMs in", outdir)
PY
