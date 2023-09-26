#!/usr/bin/perl
#echo "Determining taxonomic query terms\n";
#perl 99_uploadtaxafromkrakenncbi.pl tags_to_upload.txt ../../p01_kraken/V2/all_references_v2.txt JoyeLab_Taxonomy_v2.db

use DBI;
use strict;
use warnings;
use Term::ProgressBar;

#INICIALIZATION
my($class, $cmd, $code, $database, $dbh, @def_vec, $driver, $dsn, $error,  $family);
my($genus, $i, @input_file, $kingdom, @kingdoms, @lines, @not_kingdoms, $norank); 
my($outcmd, $order, $password, $phylum, $progress_bar, $source_id, $species, $stmt); 
my($superkingdom, @temp, @temp1, $userid);

#REFERENCE LISTS
@kingdoms = ('viruses', 'archaea', 'bacteria');
@not_kingdoms=('heunggongvirae','orthornavirae','zilligvirae','bamfordvirae','loebvirae');

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

#CONNECTING TO DB

$driver = "SQLite";
#Next line should look like this.
$database = $ARGV[2];
$dsn = "DBI:$driver:dbname=$database"; #No spaces here!!

$userid = "";
$password = "";
$dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;


#Open tags_to_upload file
open INPUT, $ARGV[0];
@input_file = <INPUT>;
close INPUT;

$progress_bar = Term::ProgressBar->new(scalar(@input_file));
$i = 0;

for ($i=0; $i < scalar(@input_file); $i++)
{
	$source_id = '_';
	$superkingdom = '_';
	$kingdom = '_';
	$phylum = '_';
	$class = '_';
	$order = '_';
	$family = '_';
	$genus = '_';
	$species = '_';

	chomp ($input_file[$i]);

	$norank = $input_file[$i];

	$cmd = "cat ".$ARGV[1]." | grep ".$norank;
	$outcmd = `$cmd`;
	chomp ($outcmd);

	@lines = split "\n", $outcmd;
	@temp = split "$norank", $lines[0];


	#SI NO ES EL CASO DE BACTERIACEAE Y LUEGO BACTERIA 
	if(scalar(@temp) <= 2){

		@temp1 = split "\;",$temp[0];
		@def_vec = @temp1;
		push(@def_vec, $norank);

		$source_id = $def_vec[0];
		$superkingdom = $def_vec[1];

		#HANDLING KINGDOM
		if(defined($def_vec[2])){
			if(in {$def_vec[2] eq $_ } @not_kingdoms){
				$kingdom = 'viruses';
			}

			if($def_vec[2] eq 'n'){
				$kingdom = $superkingdom;
			}

		}

		#HANDLING PHYLUM
		if(defined($def_vec[3])){
			
			if($def_vec[3] eq 'proteobacteria'){
				$phylum = 'pseudomonadota';
			}elsif($def_vec[3] eq 'tenericutes'){
				$phylum = 'mycoplasmatota';
			}elsif($def_vec[3] eq 'acidobacteria'){
				$phylum = 'acidobacteriota';
			}elsif($def_vec[3] eq 'actinobacteria'){
				$phylum = 'actinomycetota';
			}elsif($def_vec[3] eq 'aquificae'){
				$phylum = 'aquificota';
			}elsif($def_vec[3] eq 'bacteroidetes'){
				$phylum = 'bacteroidota';
			}elsif($def_vec[3] eq 'cyanobacteria'){
				$phylum = 'cyanobacteriota';
			}elsif($def_vec[3] eq 'firmicutes'){
				$phylum = 'bacillota';
			}elsif($def_vec[3] eq 'chloroflexi'){
				$phylum = 'chloroflexota';
			}elsif($def_vec[3] eq 'deferribacteres'){
				$phylum = 'deferribacterota';
			}elsif($def_vec[3] eq 'elusimicrobia'){
				$phylum = 'elusimicrobiota';
			}elsif($def_vec[3] eq 'fusobacteria'){
				$phylum = 'fusobacteriota';
			}elsif($def_vec[3] eq 'planctomycetes'){
				$phylum = 'planctomycetota';
			}elsif($def_vec[3] eq 'thermotogae'){
				$phylum = 'thermotogota';
			}elsif($def_vec[3] eq 'verrucomicrobia'){
				$phylum = 'verrucomicrobiota';
			}elsif($def_vec[3] eq 'chlamydiae'){
				$phylum = 'chlamydiota';
			}elsif($def_vec[3] eq 'spirochaetes'){
				$phylum = 'spirochaetota';
			}elsif($def_vec[3] eq 'synergistetes'){
				$phylum = 'synergistota';
			}elsif($def_vec[3] eq 'n'){
				$phylum = 'CHECK_PHYLUM';
			}else{
				$phylum = $def_vec[3];
			}
		}

		#HANDLING CLASS
		if(defined($def_vec[5])){
			if($def_vec[5] eq 'actinomycetia'){
				$class = 'actinomycetes';
			}elsif($def_vec[5] eq 'n'){
				$class = 'CHECK_CLASS';
			}else{
				$class = $def_vec[5];
			}
		}

		#HANDLING ORDER
		if(defined($def_vec[6])){
			if($def_vec[6] eq 'n'){
				$order = 'CHECK_ORDER';
			}else{
				$order = $def_vec[6];
			}
		}

		#HANDLING FAMILY
		if(defined($def_vec[8])){
			if($def_vec[8] eq 'n'){
				$family = 'CHECK_FAMILY';
			}else{
				$family = $def_vec[8];
			}
		}

		#HANDLING GENUS
		if(defined($def_vec[10])){
			if($def_vec[10] eq 'n'){
				$genus = 'CHECK_GENUS';
			}else{
				$genus = $def_vec[10];
			}
		}

		#HANDLING SPECIES
		if(defined($def_vec[11])){
			if($def_vec[11] eq 'n'){
				$species = 'CHECK_SPECIES';
			}else{
				$species = $def_vec[11];
				$species =~ s/\_/=/g;
			}
		}

	
	}else{#SI ES EL CASO DE BACTERIACEAE Y LUEGO BACTERIA 

		@temp1 = split "\;",$lines[0];
		@def_vec = @temp1;
		$source_id = $def_vec[0];
		$superkingdom = $def_vec[1];


		#HANDLING KINGDOM
		if(in {$def_vec[2] eq $_ } @not_kingdoms){
			$kingdom = 'viruses';
		}

		if($def_vec[2] eq 'n'){
			$kingdom = $superkingdom;
		}

		#HANDLING PHYLUM
		if($def_vec[3] eq 'proteobacteria'){
			$phylum = 'pseudomonadota';
		}elsif($def_vec[3] eq 'tenericutes'){
			$phylum = 'mycoplasmatota';
		}elsif($def_vec[3] eq 'acidobacteria'){
			$phylum = 'acidobacteriota';
		}elsif($def_vec[3] eq 'actinobacteria'){
			$phylum = 'actinomycetota';
		}elsif($def_vec[3] eq 'aquificae'){
			$phylum = 'aquificota';
		}elsif($def_vec[3] eq 'bacteroidetes'){
			$phylum = 'bacteroidota';
		}elsif($def_vec[3] eq 'cyanobacteria'){
			$phylum = 'cyanobacteriota';
		}elsif($def_vec[3] eq 'firmicutes'){
			$phylum = 'bacillota';
		}elsif($def_vec[3] eq 'chloroflexi'){
			$phylum = 'chloroflexota';
		}elsif($def_vec[3] eq 'deferribacteres'){
			$phylum = 'deferribacterota';
		}elsif($def_vec[3] eq 'elusimicrobia'){
			$phylum = 'elusimicrobiota';
		}elsif($def_vec[3] eq 'fusobacteria'){
			$phylum = 'fusobacteriota';
		}elsif($def_vec[3] eq 'planctomycetes'){
			$phylum = 'planctomycetota';
		}elsif($def_vec[3] eq 'thermotogae'){
			$phylum = 'thermotogota';
		}elsif($def_vec[3] eq 'verrucomicrobia'){
			$phylum = 'verrucomicrobiota';
		}elsif($def_vec[3] eq 'chlamydiae'){
			$phylum = 'chlamydiota';
		}elsif($def_vec[3] eq 'spirochaetes'){
			$phylum = 'spirochaetota';
		}elsif($def_vec[3] eq 'synergistetes'){
			$phylum = 'synergistota';
		}elsif($def_vec[3] eq 'n'){
			$phylum = 'CHECK_PHYLUM';
		}else{
			$phylum = $def_vec[3];
		}

		#HANDLING CLASS
		if($def_vec[5] eq 'actinomycetia'){
			$class = 'actinomycetes';
		}elsif($def_vec[5] eq 'n'){
			$class = 'CHECK_CLASS';
		}else{
			$class = $def_vec[5];
		}

		#HANDLING ORDER
		if($def_vec[6] eq 'n'){
			$order = 'CHECK_ORDER';
		}else{
			$order = $def_vec[6];
		}


		#HANDLING FAMILY
		if($def_vec[8] eq 'n'){
			$family = 'CHECK_FAMILY';
		}else{
			$family = $def_vec[8];
		}


		#HANDLING GENUS
		if($def_vec[10] eq 'n'){
			$genus = 'CHECK_GENUS';
		}else{
			$genus = $def_vec[10];
		}


		#HANDLING SPECIES
		if($def_vec[11] eq 'n'){
			$species = 'CHECK_SPECIES';
		}else{
			$species = $def_vec[11];
			$species =~ s/\_/=/g;
		}
	}
	

	print ("\nSource ID = \t".$source_id."\nSuperkingdom = \t".$superkingdom."\nKingdom = \t".$kingdom."\nPhylum = \t".$phylum."\nClass = \t".$class."\nOrder = \t".$order."\nFamily = \t".$family."\nGenus = \t".$genus."\nSpecies = \t".$species."\nNoRank = \t".$norank."\n".$norank ."\t".$lines[0]."\n");

	$stmt = $dbh->prepare('INSERT INTO TAXONOMY VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
	eval{
		$stmt->execute(undef, "ncbi", $source_id, $superkingdom, $kingdom, $phylum, $class, $order, $family, $genus, $species, $norank);
	}or do
  	{
  		$error = $@ || "error";
    	print($error."\n");
  	};              

	$progress_bar->update($i);
	$i++;
}