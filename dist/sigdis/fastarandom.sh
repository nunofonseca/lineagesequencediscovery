#!/bin/bash
#echo "usage: fastarandom.sh <FILE>"
set -e 
FILE=$1
TMPFILE1=/tmp/$$

fasta2flat.pl $FILE > $TMPFILE1
grep ">" $TMPFILE1 | sort -R | (
    while { read an; } ; do
	grep -A 1 -F "$an" $TMPFILE1
     done )
rm -f $TMPFILE1
#echo $TMPFILE1
