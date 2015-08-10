## Based on rocker / hadleyverse maintained by Carl Boettiger and Dirk Eddelbuettel
FROM rocker/hadleyverse

MAINTAINER "Petr Simecek" lamparna@gmail.com

# install additional BioC scripts
RUN install2.r --error qtl
# DOQTL and dependencies.
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("DOQTL", ask=FALSE)'
# Chesler haplotype probabilities.
RUN mkdir -p /data
RUN wget --directory-prefix=/data ftp://ftp.jax.org/dgatti/logan_haploprobs.Rdata
# Chesler phenotypes.
RUN wget --directory-prefix=/data ftp://ftp.jax.org/dgatti/logan_phenotypes.Rdata
RUN chmod --recursive 755 /data
# Sanger V5 SNPs.
RUN wget --directory-prefix=/data ftp://ftp.jax.org/sanger/current_snps/mgp.v5.merged.snps_all.dbSNP142.vcf.gz
RUN wget --directory-prefix=/data ftp://ftp.jax.org/sanger/current_snps/mgp.v5.merged.snps_all.dbSNP142.vcf.gz.tbi
