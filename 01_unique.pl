#!/usr/bin/perl
#echo "Determining taxonomic query terms\n";
#perl 01_unique.pl 00_mgrast_raw_counts.txt > 01_clean_tax_list.txt

use strict;
use warnings;
use Term::ProgressBar;

#INICIALIZATION
my($code, @fields, @fields_v2, $i, $id, @input_file, $progress_bar, $temp, $temp2, $unique_counter, @unique_query_terms);

#SUBROUTINE TO CHECK SOMETHING IS IN AN ARRAY
sub in(&@){
  local $_;
  $code = shift;
  for( @_ ){ # sets $_
    if( $code->() ){
      return 1;
    }
  }
  return 0;
}

#Open list file
open INPUT, $ARGV[0];
@input_file = <INPUT>;
close INPUT;


$progress_bar = Term::ProgressBar->new(scalar(@input_file));
$i = 0;
$unique_counter = 0;

@unique_query_terms = ();

#Check for unique terms
for ($i=0; $i < scalar(@input_file); $i++)
{
	chomp ($input_file[$i]);
	@fields = split "\t", $input_file[$i];
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

	if(!(in { $temp2 eq $_ } @unique_query_terms )){
		push @unique_query_terms, $temp2;
		$unique_counter++;
	 }
	$progress_bar->update($i);
}

foreach $id (@unique_query_terms)
{
	print($id."\n");
}