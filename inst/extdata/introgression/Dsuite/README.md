# Dsuite 渐渗分析结果

## 概述

使用 [Dsuite](https://github.com/millanek/Dsuite) (v0.5 r58) 对 `finalsnp.vcf` 进行 ABBA-BABA / D-statistic 渐渗检测。

- **工具**: Dsuite — 专为 VCF 文件设计的快速 D-statistic 和 f4-ratio 计算工具
- **数据**: 60,990 biallelic SNPs, 304 samples, 4 populations
- **外群**: PopD (91 samples, 标记为 "Outgroup")
- **内群**: PopA (65), PopB (76), PopC (72)

## 分析流程

### 1. 全局 D-statistic (Dsuite Dtrios)

```bash
Dsuite Dtrios -o dsuite_results finalsnp.vcf SETS.txt
```

计算所有可能的 trio 组合的 D 和 f4-ratio 统计量, 使用 20 个 Jackknife blocks 估计标准误和 p 值。

### 2. 窗口化局部渐渗统计 (Dsuite Dinvestigate)

```bash
Dsuite Dinvestigate -w 100,50 -n run1 finalsnp.vcf.gz SETS.txt test_trios.txt
```

在 100 SNP 窗口、50 SNP 步长下计算:
- **D**: Patterson's D statistic
- **f_d**: Martin et al. 2014 渐渗估计
- **f_dM**: Malinsky et al. 2015 修正渐渗估计
- **d_f**: Pfeifer & Kapan 2019 渐渗估计

## 结果

### 全局 D-statistic

| 比较 | D | Z-score | p-value | f4-ratio | BBAA | ABBA | BABA |
|------|---|---------|---------|----------|------|------|------|
| P1=PopB, P2=PopC, P3=PopA | 0.103 | 3.018 | **0.00254** | 0.230 | 4129 | 3618 | 2941 |
| P1=PopA, P2=PopB, P3=PopC (Dmin) | 0.066 | 1.327 | 0.185 | 0.170 | 2941 | 4130 | 3618 |

**关键发现**: PopB-PopC-PopA 比较中 D=0.103, Z=3.02, p=0.0025, 显著偏离零假设。
这表明 PopA 与 PopB 之间可能存在基因渐渗 (PopA 共享更多与 PopB 的衍生等位基因)。

### 窗口化分析 (1145 windows, 100 SNPs/window)

见 `PopB_PopC_PopA_localFstats_run1_100_50.txt`, 包含每个窗口的 D, f_d, f_dM, d_f 值。
可用于识别渐渗热点区域。

## 输出文件

| 文件 | 说明 |
|------|------|
| `SETS.txt` | 样本-群体映射 (PopD → Outgroup) |
| `dsuite_results_BBAA.txt` | 全局 D-statistic (最高 D 的 trio) |
| `dsuite_results_Dmin.txt` | Dmin 排列 (最低 D 的 trio) |
| `dsuite_results_combine.txt` | DtriosCombine 输入 |
| `dsuite_results_combine_stderr.txt` | DtriosCombine 标准误输入 |
| `finalsnp.vcf.gz` | bgzip 压缩的 VCF |
| `finalsnp.vcf.gz.tbi` | tabix 索引 |
| `PopB_PopC_PopA_localFstats_run1_100_50.txt` | 窗口化 f_d/f_dM/d_f (1145 windows) |
| `test_trios.txt` | 测试的 trio 列表 |

## 关键参数说明

| 参数 | 含义 |
|------|------|
| `-w 100,50` | 100 SNP 窗口, 50 SNP 步长 |
| `-k 20` | 20 个 Jackknife blocks (默认) |
| `Outgroup` | SETS.txt 中的外群标记关键字 |

## 参考文献

- Malinsky et al. (2021) Dsuite — fast D-statistics and related admixture evidence from VCF files. Mol Ecol Resour 21, 584–595.
- Patterson et al. (2012) Ancient admixture in human history. Genetics 192, 1065–1093.
- Martin et al. (2014) Dsuite 的 f_d 统计量.
- Malinsky et al. (2015) f_dM 修正统计量.
