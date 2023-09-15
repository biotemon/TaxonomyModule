#!/usr/bin/perl
#perl 03_generate_table.pl 00_mgrast_raw_counts.txt 02_found_in_DB.txt 03_mgrast

use DBI;
use strict;
use warnings;
use Term::ProgressBar;

#INICIALIZATION
my($cmd, @counts_file, $i, @fields, @fields_v2, @fields_v3, @fields_v4, @fields_v5, $outcmd, $progress_bar, $query, $temp, $temp2, $val, $xxx);

#Open list file
open INPUT, $ARGV[0];
@counts_file = <INPUT>;
close INPUT;

print STDERR "Reformating table\n";
$val = "GENE_ID,TAX_ID,ASSEMBLY_ID,READ_COUNTS,SOURCE,ITIS_NUMBER,SUPERKINGDOM,KINGDOM,PHYLUM,CLASS,ORDER_TAX,FAMILY,GENUS,SPECIES,NO_RANK"; 
$cmd = 'echo '.$val.'  > '.$ARGV[2].'_taxonomyXcounts.txt';
system($cmd);

$progress_bar = Term::ProgressBar->new(scalar(@counts_file));
$i = 0;


open(FH, '>>', $ARGV[2].'_taxonomyXcounts.txt') or die $!;

foreach $query (@counts_file){
	chomp ($query );
	@fields = split "\t", $query ;
	$temp = $fields[0];
	@fields_v2 = split "\;", $temp;
	$temp2 = $fields_v2[-1];
	$temp2 =~ s/\(//g;
 	$temp2 =~ s/\)//g;
 	$temp2 =~ s/\[//g;
 	$temp2 =~ s/\]//g;
	$temp2 =~ s/\'//g;
	$temp2 =~ tr/ /_/;
	$temp2 =~ s/\_sp\.$//;
	$temp2 =~ s/\_sp$//;
	$temp2 =~ s/\.$//;
	$temp2 =~ s/\./\_/g;
	$temp2 =~ s/\;/\_/g;
	$temp2 =~ s/\,/\_/g;
	$temp2 =~ s/\:/\_/g;
	$temp2 =~ s/\-/\_/g;
	$temp2 = lc($temp2);
	$temp2 =~ s/"//g;
	$temp2 =~ s/'//g;
	$temp2 =~ s/\_+/\_/g;
	$temp2 =~ s/\_\=\_/\_/;
	#print $temp2."\t".$fields[1]."\t".$fields[2]."\n";
	$cmd = 'cat '.$ARGV[1].' | grep \''.$temp2.'\'';
	$outcmd  = `$cmd`;
	@fields_v3 = split "\t", $outcmd;
	@fields_v4 = split '\|', $fields_v3[1];
	#print($fields_v3[0]."\t".$fields_v4[0]."\t".$fields[1]."\t".$fields[2]."\t".$fields_v4[1]."\t".$fields_v4[2]."\t".$fields_v4[3]."\t".$fields_v4[4]."\t".$fields_v4[5]."\t".$fields_v4[6]."\t".$fields_v4[7]."\t".$fields_v4[8]."\t".$fields_v4[9]."\t".$fields_v4[10]."\t".$fields_v4[11]."\n");
	#$val = $record.'$\'\t\''.$fields[0].'$\'\t\''.$sample_id.'$\'\t\''.$the_counts.'$\'\t\''.$row[1].'$\'\t\''.$row[2].'$\'\t\''.$row[3].'$\'\t\''.$row[4].'$\'\t\''.$row[5].'$\'\t\''.$row[6].'$\'\t\''.$row[7].'$\'\t\''.$row[8].'$\'\t\''.$row[9].'$\'\t\''.$row[10].'$\'\t\''.$row[11].'$\'\t\''.$row[12];
	$val = $fields_v3[0].",".$fields_v4[0].",".$fields[1].",".$fields[2].",_,_,".$fields_v4[3].",".$fields_v4[4].",".$fields_v4[5].",".$fields_v4[6].",".$fields_v4[7].",".$fields_v4[8].",".$fields_v4[9].",".$fields_v4[10].",".$fields_v4[11];
	$val =~ s/\R//g;
	@fields_v5 = split ",", $val;
	if(scalar(@fields_v5) == 15)
	{
		print FH $val."\n";
	}	
	#$cmd = 'echo '.$val.'  >> '.$ARGV[2].'_taxonomyXcounts.txt';
	#system($cmd);
	$progress_bar->update($i);
	$i++;
}

close(FH);