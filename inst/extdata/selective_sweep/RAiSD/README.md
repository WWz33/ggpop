# RAiSD 选择性清除分析

## 概述

使用 [RAiSD v2.9](https://github.com/alachins/raisd) 对 4 个大豆群体进行选择性清除 (selective sweep) 检测。

- **数据**: 60,990 SNPs, 304 samples, 4 populations
- **参考基因组**: Gmax_a4.v1 (GFF: Gmaxa4.gff3)

## 分析流程

```bash
# 1. 运行 RAiSD (每群体, 20条染色体)
raisd -n PopA -I input.vcf -R -A 0.95 -S PopA.list -f

# 2. 合并染色体报告, 提取 mu statistic
# 3. Z-score 标准化
python3 zscore.py RAiSD_Report.PopA.all RAiSD_Report.PopA.all.zscore

# 4. 筛选 outlier (Z >= 1.96, ±50kb 窗口)
# 5. 映射到基因 (GFF overlap)
python3 GetGeneFromGFF.py reference.gff3 outliers.pos genes.out
```

## 结果

| 群体 | SNP数 | Outlier数 (Z≥1.96) | 候选基因数 |
|------|-------|---------------------|-----------|
| PopA | 58,613 | 2,112 | 4,504 |
| PopB | 56,893 | 2,107 | 4,501 |
| PopC | 57,845 | 2,232 | 5,515 |
| PopD | 59,775 | 2,207 | 4,916 |

## 输出文件

| 文件 | 说明 |
|------|------|
| `RAiSD_Report.{Pop}.all.zscore` | 全基因组 Z-score (chrom, pos, mu, zscore) |
| `RAiSD_Report.{Pop}.all.zscore.pos.genes.clean` | 候选基因列表 (去重) |
| `{Pop}.list` | 群体样本列表 |
| `reference.gff3` | External GFF3 annotation supplied by the user; not bundled because the full file is larger than GitHub's 100 MB file limit. |
| `zscore.py` | Z-score 标准化脚本 |
| `GetGeneFromGFF.py` | 区间→基因映射脚本 |

## 关键参数

- `-R`: 输出详细报告 (含 Var, SFS, LD, MuStat)
- `-A 0.95`: 分析阈值
- `-S`: 指定群体样本列表
- Z-score 阈值: 1.96 (p<0.05)
- 基因映射窗口: ±50kb

## 参考文献

- Alachiotis & Pavlidis (2018) RAiSD detects positive selection based on multiple signatures of a selective sweep. Communications Biology 1, 86.
