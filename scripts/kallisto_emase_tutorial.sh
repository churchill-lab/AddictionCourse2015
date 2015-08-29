#!/usr/bin/env bash

kallisto index \
    -i individualized.transcriptome.idx \
    /kbdata/individualized.transcriptome.fa.gz

kallisto-align \
    -f /kbdata/rawreads.fastq.gz \
    -i individualized.transcriptome.idx \
    -b pseudo-alignments.EC.bin

emase-zero -v --model 4 \
    -b pseudo-alignments.EC.bin \
    -o emase.m4.expected_read_counts

kallisto-to-emase \
    -i pseudo-alignments.EC.bin \
    -a pseudo-alignments.EC.h5
