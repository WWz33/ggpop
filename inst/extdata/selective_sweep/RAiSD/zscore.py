#!/usr/bin/env python3
"""Z-score standardization of RAiSD scores (handles scientific notation)."""
import sys, numpy as np

infile = sys.argv[1]
outfile = sys.argv[2]

data = []
with open(infile) as f:
    for line in f:
        parts = line.split()
        if len(parts) >= 4:
            data.append(parts)

scores = np.array([float(row[3]) for row in data], dtype=np.float64)
mu = np.mean(scores)
sigma = np.std(scores, ddof=1) if len(scores) > 1 else 1.0

with open(outfile, "w") as out:
    for i, row in enumerate(data):
        z = (scores[i] - mu) / sigma if sigma > 0 else 0
        out.write(f"{row[0]}\t{row[1]}\t{row[2]}\t{row[3]}\t{z:.6f}\n")

print(f"Processed {len(data)} sites, mu={mu:.6e}, sigma={sigma:.6e}")
