## Based on rocker / hadleyverse maintained by Carl Boettiger and Dirk Eddelbuettel
FROM rocker/hadleyverse

MAINTAINER "Petr Simecek" lamparna@gmail.com

# install additional BioC scripts
RUN install2.r --error qtl
RUN Rscript -e 'source("http://bioconductor.org/biocLite.R"); biocLite("DOQTL", ask=FALSE)'
RUN mkdir -p /data \
    wget --directory-prefix=/data ftp://ftp.jax.org/dgatti/chesler_haploprobs.Rdata
RUN chmod --recursive 755 /data
