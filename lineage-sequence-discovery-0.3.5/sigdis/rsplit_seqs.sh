#!/bin/bash
# usage: rsplit_seqs <inline/flat fasta file> <NSEQS>
#set -e
TMP1=`mktemp`
N=`expr $2 \* 2`
fastarandom.sh $1 > $TMP1
head -n $N  $TMP1 > $1.train
tail -n +`expr $N + 1` $TMP1 > $1.test
