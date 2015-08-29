#################
# R script for Differential Expression analysis 
# using DESEQ2
##################
library("DESeq2")
setwd("/deseq/")

#### load the expression data as read counts from DO Hippocampus RNA-seq samples 
exp = read.table("Hippocampus_Exp_for_DE_analysis.txt", header=T)
colnames(exp)=gsub("X","",colnames(exp))

#### load the experimental design file for the Hippocampus DO RNA-seq data
exp_design = read.table("Hippocampus_Exp_Design_for_DE_analysis.txt",header=T)

#### check the expression data and design file has the same set of animals in the same order
all(colnames(exp)==exp_design$Mouse.ID)

### Create data frames for DESeq2 object
### colData contains the condition/group information for Differenetial expression analysis
colData <- DataFrame(group = factor(exp_design$Sex))

### Create DESeq2 object using expression and colData
dds <- DESeqDataSetFromMatrix(countData = as.data.frame(round(exp)),
         colData = colData, design = ~ group)
dds <- DESeq(dds)
res = results(dds)

### summary of Differential Expression analysis
summary(res)

### Plot M-A plot
pdf("Hippocampus-DO-MA-plot.pdf")
plotMA(res, main="DESeq2", ylim=c(-2,2))
dev.off()

#### plot read counts for the most significant gene
pdf("Hippocampus-strongest-sex-effect.pdf")
plotCounts(dds, gene=which.min(res$padj), intgroup="group")
dev.off()
mcols(res)

#### write the results as a file
resOrdered <- res[order(res$padj),]
write.csv(as.data.frame(resOrdered), file="sex_effect_results.csv")

pdf("pvalue-hist.pdf")
hist(res$pvalue,breaks=100,col="grey", xlab="p-value",main="")
dev.off()


