#!/usr/bin/perl
#perl 02_finder.pl JoyeLab_Taxonomy_v2.db 01_clean_tax_list.txt > 02_found_in_DB.txt

use DBI;
use strict;
use warnings;
use Term::ProgressBar;

#INICIALIZATION
my($cmd, $database, $dbh, $driver, $dsn, @fields, $i, @input_file, $outcmd, $password, $progress_bar, $query, $record, %taxid_of, $userid);

#--OPEN FILES--
$database = './'.$ARGV[0];
$driver = "SQLite";
$dsn = "DBI:$driver:dbname=$database"; #No spaces here!!
$userid = "";
$password = "";
$dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 })
or die $DBI::errstr;

#Open list file
open INPUT, $ARGV[1];
@input_file = <INPUT>;
close INPUT;

print STDERR "Scanning entries in DB\n";

$progress_bar = Term::ProgressBar->new(scalar(@input_file));
foreach $query (@input_file){
	chomp($query);
	$outcmd = undef;
	$cmd = "sqlite3 ".$database." \"SELECT * FROM TAXONOMY WHERE NO_RANK = \'".$query."\';\"";
	$outcmd = `$cmd`;
	if($outcmd){
	 	#print("We found taxonomy using the no_rank field ".$fields[0]."\n"); 
	 	$taxid_of{$query}=$outcmd;
	}else
	{
		print($cmd."\n");
		print("We didn't find taxonomy using the no_rank field for\t".$query."\n");
	}
	$progress_bar->update($i);
	$i++;
}


print STDERR "Printing records found in DB\n";

$progress_bar = Term::ProgressBar->new(scalar(keys %taxid_of));
$i = 0;
foreach $record (keys %taxid_of){
	chomp($taxid_of{$record});
	print($record."\t".$taxid_of{$record}."\n");
	$progress_bar->update($i);
	$i++;
}