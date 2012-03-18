#!/usr/bin/perl -w
#echo "usage: fasta_flat.sh fasta_file"
# removes the 80 chars boundary on each fasta line

my $file=$ARGV[0];

if ( scalar(@ARGV)<1 ) {
    print STDERR << "EOF";
Error: Usage: fasta_flat fasta_file
EOF
	exit(1);
}
my $start=0;
open(FD,$file) || die "Unable to open $file\n";
$_=<FD>;
while (!eof(FD)) {
#"$_" ne ""
    if ( /^>/ ) {
	$start=1;
	s/\n//;
	print "$_\n";
	if (eof(FD)) { close(FD);exit(0); }
	$_=<FD>;
	while ( /^[A-Za-z\-]/ ) {
	    s/\n//;
	    print ;
	    if ( eof(FD) ) { print "\n";close(FD);exit(0); }
	    $_=<FD>;
	}
	print "\n";
    } else {
#	if ( $start==1 ) {
#	    print STDERR "Invalid fasta header: $_\n";
#	    exit(1);
#	}
	$_=<FD>;
    }
    chomp;
}
close(FD);
exit(0);
