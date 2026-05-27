#!/usr/bin/env python3
"""Find genes overlapping outlier regions.
Usage: python GetGeneFromGFF.py <gff_file> <regions_file> <output_file>
regions_file: chr start end (one per line)
"""
import sys

gff_file = sys.argv[1]
regions_file = sys.argv[2]
out_file = sys.argv[3]

# Read outlier regions
regions = []
with open(regions_file) as f:
    for line in f:
        parts = line.split()
        if len(parts) >= 3:
            chrom = parts[0]
            start = int(float(parts[1]))
            end = int(float(parts[2]))
            regions.append((chrom, start, end))

# Read GFF and find overlaps
results = []
with open(gff_file) as f:
    for line in f:
        if line.startswith("#"):
            continue
        parts = line.strip().split("\t")
        if len(parts) < 9:
            continue
        if parts[2] != "gene":
            continue
        g_chrom = parts[0]
        g_start = int(parts[3])
        g_end = int(parts[4])
        g_attr = parts[8]
        
        for r_chrom, r_start, r_end in regions:
            if g_chrom == r_chrom and g_start <= r_end and g_end >= r_start:
                results.append(line.strip())
                break

with open(out_file, "w") as out:
    out.write("#chr\tsource\ttype\tstart\tend\tscore\tstrand\tphase\tattributes\n")
    for r in results:
        out.write(r + "\n")

print(f"Found {len(results)} genes overlapping {len(regions)} outlier regions")
