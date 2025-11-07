#!/usr/bin/env bash
# Usage: bash 03_generate_reports.sh config.yaml
CONFIG=$1
python - <<PY
import yaml, os, subprocess
cfg=yaml.safe_load(open("$CONFIG"))
proj=cfg['project_dir']
aligndir=os.path.join(proj,"alignments")
methdir=os.path.join(proj,"methylation")
reports=os.path.join(proj,"reports")
os.makedirs(reports, exist_ok=True)
# bismark2report & summary
subprocess.run(["bismark2report","--alignment_report", aligndir])
subprocess.run(["bismark2summary"])
# run MultiQC in project root
subprocess.run(["multiqc", proj, "-o", reports])
print("Reports generated in", reports)
PY
