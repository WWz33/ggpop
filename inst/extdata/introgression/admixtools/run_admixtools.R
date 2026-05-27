library(admixtools)
setwd("/home/ww/test/Introgression/admixtools")

f2_blocks = f2_from_geno("finalsnp", maxmiss = 0.5, blgsize = 0.05)

# 1. qpDstat
cat("=== qpDstat ===\n")
dstat = qpdstat(f2_blocks, "PopB", "PopC", "PopA", "PopD")
print(dstat)
write.csv(dstat, "qpdstat_result.csv", row.names=FALSE)

# 2. f4-ratio: f4(PopB,PopC; PopA,PopD) / f4(PopB,PopC; PopB,PopD)
cat("\n=== f4-ratio ===\n")
f4r = qpf4ratio(f2_blocks, c("PopB", "PopC", "PopA", "PopD", "PopB"))
print(f4r)
write.csv(f4r, "f4ratio_result.csv", row.names=FALSE)

# 3. f3
cat("\n=== f3 ===\n")
f3r = rbind(
  f3(f2_blocks, "PopA", "PopB", "PopC"),
  f3(f2_blocks, "PopA", "PopB", "PopD"),
  f3(f2_blocks, "PopA", "PopC", "PopD"),
  f3(f2_blocks, "PopB", "PopC", "PopD"))
print(f3r)
write.csv(f3r, "f3_result.csv", row.names=FALSE)

# 4. qpAdm
cat("\n=== qpAdm ===\n")
tryCatch({
  adm = qpadm(f2_blocks, c("PopB", "PopC"), c("PopD"), "PopA")
  cat("Weights:\n"); print(adm$weights)
  write.csv(adm$weights, "qpadm_weights.csv", row.names=FALSE)
  cat("Rank p:", adm$rankdrop$p, "\n")
}, error = function(e) cat("Error:", e$message, "\n"))

# 5. qpWave
cat("\n=== qpWave ===\n")
tryCatch({
  wave = qpwave(f2_blocks, c("PopB", "PopC"), c("PopD"))
  cat("Rank p:", wave$rankdrop$p, "\n")
  write.csv(wave$rankdrop, "qpwave_result.csv", row.names=FALSE)
}, error = function(e) cat("Error:", e$message, "\n"))

cat("\n=== DONE ===\n")
