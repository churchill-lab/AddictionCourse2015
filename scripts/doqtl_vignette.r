### R code from vignette source 'QTL_Mapping_DO_Mice.Rnw'

###################################################
### code chunk number 1: setup
###################################################
library(DOQTL)
library(MUGAExampleData)
data(pheno)
data(model.probs)


###################################################
### code chunk number 2: kinship
###################################################
K = kinship.probs(model.probs)


###################################################
### code chunk number 3: covar
###################################################
covar = data.frame(sex = as.numeric(pheno$Sex == "M"), diet = as.numeric(pheno$Diet == "hf"))
rownames(covar) = rownames(pheno)


###################################################
### code chunk number 4: snps
###################################################
load(url("ftp://ftp.jax.org/MUGA/muga_snps.Rdata"))


###################################################
### code chunk number 5: scanone
###################################################
qtl = scanone(pheno = pheno, pheno.col = "HDW2", probs = model.probs, K = K,
              addcovar = covar, snps = muga_snps)


###################################################
### code chunk number 6: perms
###################################################
perms = scanone.perm(pheno = pheno, pheno.col = "HDW2", probs = model.probs, 
        addcovar = covar, snps = muga_snps, nperm = 100)
thr = quantile(perms, probs = 0.95)


###################################################
### code chunk number 7: qtlplot
###################################################
plot(qtl, sig.thr = thr, main = "HDW2")


###################################################
### code chunk number 8: fig1
###################################################
plot(qtl, sig.thr = thr, main = "HDW2")


###################################################
### code chunk number 9: coefplot
###################################################
coefplot(qtl, chr = 9)


###################################################
### code chunk number 10: fig2
###################################################
coefplot(qtl, chr = 9)


###################################################
### code chunk number 11: QTL_Mapping_DO_Mice.Rnw:177-179
###################################################
interval = bayesint(qtl, chr = 9)
interval


###################################################
### code chunk number 12: mergeplot
###################################################
ma = assoc.map(pheno = pheno, pheno.col = "HDW2", probs = model.probs, K = K,
                    addcovar = covar, snps = muga_snps, chr = interval[1,2], 
                    start = interval[1,3], end = interval[3,3])
tmp = assoc.plot(ma, thr = 4)
unique(tmp$sdps)


###################################################
### code chunk number 13: fig3
###################################################
ma = assoc.map(pheno = pheno, pheno.col = "HDW2", probs = model.probs, K = K,
                    addcovar = covar, snps = muga_snps, chr = interval[1,2], 
                    start = interval[1,3], end = interval[3,3])
tmp = assoc.plot(ma, thr = 4)
unique(tmp$sdps)


###################################################
### code chunk number 14: get_genes
###################################################
mgi = get.mgi.features(chr = interval[1,2], start = interval[1,3],
      end = interval[3,3], type = "gene", source = "MGI")
nrow(mgi)
head(mgi)


###################################################
### code chunk number 15: sessionInfo
###################################################
sessionInfo()



