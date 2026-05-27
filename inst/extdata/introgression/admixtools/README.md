# ADMIXTOOLS 2 渐渗分析

## 概述

使用 [ADMIXTOOLS 2](https://github.com/uqrmaie1/admixtools) (R 包) 进行 f-statistic 渐渗检测。

- **工具**: ADMIXTOOLS 2 (v8.0.2 R package + v8.0.2 C++ backend)
- **数据**: 60,990 SNPs, 304 samples, 4 populations
- **外群**: PopD (91 samples)

## 结果

### qpDstat (D-statistic)

```
P1=PopB, P2=PopC, P3=PopA, P4=PopD
D = -0.0111, SE = 0.00185, Z = -5.99, p = 2.16e-9
```

显著偏离零 → PopA 与 PopC 共享更多衍生等位基因（相对于 PopB）

### f4-ratio

```
f4(PopB,PopC; PopA,PopD) / f4(PopB,PopC; PopB,PopD)
alpha = -0.308, SE = 0.0506, Z = -6.09
```

PopA 约 30.8% 的祖先来自与 PopB 相关的谱系

### f3 (admixture test)

| Target | Source1 | Source2 | f3 | SE | Z | p |
|--------|---------|---------|-----|------|------|------|
| PopA | PopB | PopC | 0.054 | 0.005 | 11.5 | 1.07e-30 |
| PopA | PopB | PopD | 0.046 | 0.003 | 15.9 | 4.87e-57 |
| PopA | PopC | PopD | 0.035 | 0.003 | 11.9 | 9.75e-33 |
| PopB | PopC | PopD | 0.036 | 0.003 | 13.5 | 9.92e-42 |

所有 f3 均显著正值 → PopA 和 PopB 都显示混合信号

### qpWave (clade test)

```
left = [PopB, PopC], right = [PopA, PopD]
Rank 0 p-value = 2.17e-9
```

拒绝零假设 → PopB 和 PopC 不形成 clade（存在分化）

### qpAdm

需要 ≥2 个 right populations，4 群体数据不足，未运行。

## 输出文件

| 文件 | 说明 |
|------|------|
| `qpdstat_result.csv` | D-statistic (D, SE, Z, p) |
| `f4ratio_result.csv` | f4-ratio (alpha, SE, Z) |
| `f3_result.csv` | f3 admixture test (4 组合) |
| `run_admixtools.R` | 完整 R 分析脚本 |

## 与其他工具对比

| 工具 | 统计量 | 值 | Z | p |
|------|--------|-----|------|------|
| ADMIXTOOLS 2 | D | -0.011 | -5.99 | 2.16e-9 |
| Dsuite | D | 0.103 | 3.02 | 2.54e-3 |
| ADMIXTOOLS 2 | f4-ratio α | -0.308 | -6.09 | — |
| Dsuite | f4-ratio | 0.230 | — | — |

注: D 值符号不同是因为 ADMIXTOOLS 和 Dsuite 的 D 公式符号约定不同，方向一致。

## 参考文献

- Maier et al. (2023) ADMIXTOOLS 2: speedup and new methods. Bioinformatics.
- Patterson et al. (2012) Ancient admixture in human history. Genetics.
