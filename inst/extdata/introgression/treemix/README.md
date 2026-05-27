# TreeMix 渐渗分析结果

## 概述

使用 [TreeMix v1.13](https://bitbucket.org/nygcresearch/treemix) 推断群体历史关系和迁移事件。
参考流程: [ScricptsForSoybean/TreeMix](https://github.com/sibs-zz/ScricptsForSoybean/tree/b3c2068f/TreeMix)

- **数据**: 60,990 SNPs, 304 samples, 4 populations
- **外群/根**: PopD (91 samples)
- **内群**: PopA (65), PopB (76), PopC (72)

## 分析流程

```bash
# 1. VCF → PLINK
plink2 --vcf finalsnp.vcf --make-bed --out treemix --allow-extra-chr --set-missing-var-ids @:#

# 2. 分群体等位基因频率
plink --bfile treemix --chr-set 20 --freq gz --within treemix.information.txt --out treemix

# 3. PLINK → TreeMix 格式
python3 plink2treemix.py treemix.frq.strat.gz treemix.frq.gz

# 4. TreeMix (m=0~15, k=10000, bootstrap=100, noss)
for m in {0..15}; do
  treemix -i treemix.frq.gz -root PopD -m $m -o treemix.M${m} \
    -k 10000 -bootstrap 100 -noss -global
done
```

关键参数:
- `-k 10000`: 每个block 10000个SNP (用于协方差矩阵估计)
- `-bootstrap 100`: 100次bootstrap评估分支可靠性
- `-noss`: 不做样本量校正
- `-global`: 添加所有群体后做全局重排

## 结果

### Likelihood 趋势 (选择最优 m)

| m (迁移边) | ln(likelihood) | 说明 |
|-----------|----------------|------|
| 0 | 30.51 | 纯树, 无迁移 |
| **1~7** | **66.29** | **最优, 1条迁移边即足够** |
| 8~13 | 65.63 | 过拟合, likelihood下降 |
| 14~15 | 65.40 | 严重过拟合 |

**最优模型: m=1** (1条迁移边)

### 树结构 (m=1)

```
(PopD:0.003, ((PopC:0.004, PopB:0.020):0.013, PopA:0.006):0.003);
```

Newick 树 (可视化):
```
           ┌── PopC
      ┌────┤
      │    └── PopB
 ─────┤
      │    ┌── PopA
      └────┤
           └── PopD (root)
```

### 迁移边 (m=1)

```
迁移: PopB/PopC祖先节点 → PopD
权重: 0.397 (即 ~40% 的 PopD 基因组来自 PopB/PopC 祖先)
Bootstrap支持: 0.397 (consensus tree 一致)
```

### 与其他工具对比

| 工具 | 检测到的渐渗信号 | 显著性 |
|------|------------------|--------|
| **Dsuite** | PopA↔PopB (D=0.103) | p=0.0025 ✓ |
| **TreeMix** | PopB/PopC祖先→PopD (weight=0.397) | bootstrap一致 |
| genomics_general | PopA↔PopB (方向一致) | 数据稀疏,不可靠 |

注: Dsuite 和 TreeMix 检测到不同方向的渐渗信号, 可能因为:
- Dsuite 检测的是近期的种群间基因流
- TreeMix 检测的是祖先节点间的迁移事件

## 输出文件

| 文件 | 说明 |
|------|------|
| `treemix.frq.gz` | TreeMix 输入 (60990 SNPs, 4 pops) |
| `treemix.M0.treeout.gz` | m=0 Newick 树 (无迁移) |
| `treemix.M1.treeout.gz` | m=1 Newick 树 + 迁移边 (最优模型) |
| `treemix.M{0,1}.cov.gz` | 观测遗传协方差矩阵 |
| `treemix.M{0,1}.modelcov.gz` | 模型拟合协方差矩阵 |
| `treemix.M{0,1}.edges.gz` | 边/迁移信息 |
| `treemix.M{0,1}.llik` | likelihood 日志 |
| `treemix.M{0,1}.vertices.gz` | 节点信息 |
| `treemix.M{0,1}.covse.gz` | 协方差标准误 |
| `plink2treemix.py` | PLINK → TreeMix 格式转换脚本 |

## 参考文献

- Pickrell & Pritchard (2012) Inference of population splits and mixtures from genome-wide allele frequency data. PLoS Genetics 8, e1002967.
