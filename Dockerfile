## Based on rocker / hadleyverse maintained by Carl Boettiger and Dirk Eddelbuettel
FROM rocker/hadleyverse

MAINTAINER "Daniel Gatti" dan.gatti@jax.org

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

