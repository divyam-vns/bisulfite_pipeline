#!/usr/bin/env bash
# Usage: bash 00_trim_galore.sh config.yaml
CONFIG=$1
if [ -z "$CONFIG" ]; then echo "Usage: $0 config.yaml"; exit 1; fi

python - <<PY
import yaml, pandas as pd, os, subprocess, sys
cfg=yaml.safe_load(open("$CONFIG"))
fastq_dir=cfg['fastq_dir']
outdir=os.path.join(cfg['project_dir'],"trimmed")
os.makedirs(outdir, exist_ok=True)
samples=pd.read_csv(cfg['samples_table'], sep='\\t')
for idx,row in samples.iterrows():
    s=row['sample_id']
    r1=os.path.join(fastq_dir, row['r1'])
    r2=os.path.join(fastq_dir, row['r2']) if not pd.isna(row['r2']) else None
    cmd=["trim_galore","--paired"] if r2 else ["trim_galore"]
    if cfg.get('is_rrbs', False):
        cmd += ["--rrbs"]
    if cfg.get('trim_extra_args'):
        cmd += cfg['trim_extra_args'].split()
    cmd += ["-o", outdir, r1]
    if r2:
        cmd += [r2]
    print("Running:", " ".join(cmd))
    subprocess.run(cmd)
print("Trim Galore step complete. Trimmed files in", outdir)
PY
