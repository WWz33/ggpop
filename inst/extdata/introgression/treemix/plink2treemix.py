#!/usr/bin/env python3
"""Convert PLINK frq.strat.gz to TreeMix input format."""
import sys, gzip
from collections import defaultdict

infile = sys.argv[1]
outfile = sys.argv[2]

# Read frq.strat.gz
data = defaultdict(dict)  # {snp: {pop: (mac, nchrobs)}}
pops = set()

with gzip.open(infile, 'rt') as f:
    header = f.readline()
    for line in f:
        parts = line.split()
        if len(parts) < 8:
            continue
        chrom, snp, clst, a1, a2, maf, mac, nchrobs = parts
        mac = int(mac)
        nchrobs = int(nchrobs)
        if nchrobs == 0:
            continue
        data[snp][clst] = (mac, nchrobs)
        pops.add(clst)

pops = sorted(pops)

# Write TreeMix format
with gzip.open(outfile, 'wt') as out:
    out.write(" ".join(pops) + "\n")
    for snp in data:
        if len(data[snp]) != len(pops):
            continue  # skip SNPs missing in any population
        vals = []
        for pop in pops:
            mac, nchrobs = data[snp][pop]
            vals.append(f"{mac},{nchrobs}")
        out.write(" ".join(vals) + "\n")

print(f"Written {len(data)} SNPs, {len(pops)} populations to {outfile}")
