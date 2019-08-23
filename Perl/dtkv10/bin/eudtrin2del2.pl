#!/usr/bin/perl
=for comment
Dette modul skal køres efter eudtrin1.pl og læser de enkelte elevtyper
fra ordningen.
 1: Sammenlign elevtyper - hvis der er nogle der er ens. Sammenlæg dem
 2: Opret tabel fag for hver enkelt fag. Må kun eksistere en gang
 3: Opret faginstans som er en konkret instans af det enkelte fag
    Et fag kan eksistere med niveauer (rutine, avanceret) og 
    forskellige fagtyper (Valgfri, bundet) osv.
 4: Opret mådpinde til faginstans - kan være forskellige (Ekspert)
 5: Opret resultatform(e) til faget
 6: Kombiner faginstans med det enkelte speciale, elevtype og 
    ordning. Fx. IT-Support, EUD og ungdom og Data version 10

create_fag()				# Returnet fag_id
create_faginstans()			# Returner faginstans_id
create_resultatform()
create_pind()
create_kombiner_fag_spc()
create_kombiner_fag_pin()


fortsæt med eudtrin3
=cut
 
select(STDERR);
$|=1;
select(STDOUT);
$|=1;
use strict;
use warnings;
use lib '.';
use Storable;
use DBI;
#use utf8;
use Config::Simple;

#Globale variable - makes life easier (but unsafe :-)
#database handles
my $dbh;
my $sth;
my @eta; #ElevTypeArray


# SUBS
sub usage {
	printf("$0 ordning_id fra trin1\n");
	exit;
}

#Konverter dato string fra DD-MM-YYYY til YYYY-MM-DD
sub sqldate {
	my $date = shift;
	$date =~ /(\d+)-(\d+)-(\d+)/;
	$date =  "$3-$2-$1";
return($date);
}
#Padder en tekst streng $str med tegnet $padding
sub pad {
    my ($str, $padding, $length) = @_;

    my $pad_length = $length - length $str;
    $pad_length = 0 if $pad_length < 0;
    $padding x= $pad_length;
    $str.$padding;
}
#Opretter speciale i databasen inkl fag og faginstanser
#Opretter tabeller i tabel kombiner som kombinerer fag-
#instanser og specialer.
sub speciale_create {
	my $elevtype = shift;
	my $speciale = shift;    # Last line in @eta
	my $line;
	# Faginstans variable
	my (
        $fagnr, 
        $fagnavn,
        $niveau, 
        $fagkat, 
        $fagtype, 
        $fag_id, 
        $opr_varighed, 
        $afkortning, 
        $varighed, 
        $tilknyt,
    );
    my @resultatformer = ();
    my @pinde = ();
	printf("Opretter elevtype %i - speciale %s\n",$elevtype,$speciale);
	$sth = $dbh->prepare("INSERT INTO speciale (speciale, elevtype_id) VALUES (?,?)");
	$sth->execute($speciale, $elevtype) or die $DBI::errstr;
	my $lineusedflag=0;
	while ( $line = shift( @eta )) {  
		#$lineusedflag=0;
		#Anvender statemachine i stedet for!!!
	#Snyder lidt - unshifter linje hvis næste speciale
		if ( $line =~ /^<SPCFAG>.*|^<COMMON>.*/ ) { # 
			unshift(@eta, $line);
			last;
		}
		#Opret fag, faginstans og kombiner tables
		if ( $line =~ /^<OVRIGE>.*/ ) {  # Drop linje
			next;
		}
		if ( $line =~ /^<FAG   >(\d+)\s+(.+)$/) {
			$fagnr=$1;			# Fx. 1590
			$fagnavn = $2;		# Fx. Fiberinstallation
				#printf("Fag færdig %i - %i\n", $fagnr, $#pinde+1);
			#$lineusedflag=1;  #Line content found
			if ( $lineusedflag==1 ) {
				#printf("Fag færdig %i - %i\n", $fagnr, $#pinde+1);
				 $lineusedflag=0;
			}
		}
		if ( $line =~ /^<NIVEAU>(.+)$/ ) {
			$niveau = $1;
			$lineusedflag=1;  #Line content found
		}
		if ( $line =~ /^<OPRVAR>(.*)$/ ) {
			$opr_varighed = $1;	# NOgle praktikfag har ingen tid - sæt til '-'
			if ( !$opr_varighed ) {
				$opr_varighed = '-';
			}
			$lineusedflag=1;  #Line content found
		}
		if ( $line =~ /^<FAGKAT>(.+)$/ ) {
			$fagkat = $1;
			$lineusedflag=1;  #Line content found
		}
		if ( $line =~ /^<TYPE  >(.+)$/ ) {
			$fagtype = $1;
			$lineusedflag=1;  #Line content found
		}
		if ( $line =~ /^<FRA   >(.+)$/ ) {
			my $tilknyt = $1;
			$lineusedflag=1;  #Line content found
		}
		if ( $line =~ /^<AFKORT>(.+)$/ ) {
			$afkortning = $1;
			$lineusedflag=1;  #Line content found
		} 
		if ( $line =~ /^<VARIG >(.+)$/ ) {
			$varighed = $1;
			$lineusedflag=1;  #Line content found
		} 
		if ( $line =~ /^<RESUL1>(.+)$/ ) {
			push(@resultatformer,$1);
			$lineusedflag=1;  #Line content found
		} 
		if ( $line =~ /^<RESUL2>(.+)$/ ) {
			push(@resultatformer,$1);
			$lineusedflag=1;  #Line content found
		} 
		if ( $line =~/^<PINDST>/ ) { #Start på målepinde
			# Do nothing
		}
		if ( $line =~ /^<PIND  >(\d+)\s+(.+)\s+(\d\d-\d\d-\d\d\d\d og fremefter)$/ ) {
			push(@pinde,[$1,$2,$3]);	# Tilføj pind til array
			if ( defined $eta[0] ) {
				#printf("ETA: %s\n", $eta[0] );
				if ( $eta[0] =~ /^<PIND\+ >(.+)$/ ) { 
					#printf("%5i: %s\n",  $pinde[$#pinde][0],  $pinde[$#pinde][1]);
					$pinde[$#pinde][1] =  $pinde[$#pinde][1] . " " . $1;
					shift( @eta );
					#printf("%5i: %s\n",  $pinde[$#pinde][0],  $pinde[$#pinde][1]);
				}
			}
			# DEBUG HeTh - printf("%5i: %s\n",  $pinde[$#pinde][0],  $pinde[$#pinde][1]);
			 #$lineusedflag=0;

            #Insert all the data? since you have everything seperated here
            print $fagnr;
            print $fagnavn;
            print $tilknyt;
            print $opr_varighed;
            print $niveau;
            print $fagkat;
            print $fagtype;
            print $fag_id;
            print $afkortning;
            print $varighed;
            print @resultatformer;
            print @pinde;


			#printf("[%i][%s][%s]\n",$1,$2,$3);
			#printf("HER: %i %s\n",$fagnr,$fagnavn);
			#printf("Fagnr %i %s tilknyt: %s opr_varighed: %s\n", $fagnr, $fagnavn,$tilknyt, $opr_varighed);
			#printf("Niveau: %s fagkat: %s fagtype: %s\n", $niveau, $fagkat, $fagtype);
			#for ( my $i=0; $i <= $#resultatformer; $i++) {
			#	printf("Resultat: %s\n",$resultatformer[$i]);
			#}
            # Tøm variable til fag og faginstans
            undef $fagnr; undef $fagnavn; undef $tilknyt; undef $opr_varighed;
            undef $niveau; undef $fagkat; undef $fagtype; undef $fag_id;
            undef $afkortning; undef $varighed;
            undef @resultatformer; undef @pinde;
            #		exit(0);
			$lineusedflag=1;  #Line content found
		}	
		if ( $lineusedflag == 0 ) {		#Unknown line error
			#die("Line not used error: $line");
		}
	}
}

#Opretter elevtype med specialer, fag og faginstanser
#i databasen.
# Anvender sub speciale() for hvert speciale. Fælles??
sub elevtype_create { # Do it all
	my $elevtype = shift;

	#Specialer skal findes og speciale_create oprettes.
    #Hent alle linjer i elevtype fra databasen til @eta
	elevtype_read(\@eta,$elevtype);	
	#Tøm @eta fra bunden og op
	while ( my $line = shift( @eta ) ) {
			#printf("elevtype_create: %s - ", $line);
		if ( $line =~ /^<COMMON>.*/ ) { #Fællesfag
			#printf("elevtype_create: %s\n", "Fællesfag");
			speciale_create($elevtype, "Fællesfag");
		} #/*IF EXISTS*/
		if ( $line =~ /^<SPCFAG>(.*)/ ) { #Fællesfag
			#printf("elevtype_create: %s\n", $1);
			speciale_create($elevtype, $1);
		}
	}
}
	
#Læser elevtyperaw fra databsen.
#Databasen skal være åben
sub elevtype_read {
	my $elev_ref = shift;
	my $elevtype_id = shift;
	my @tmparr1;
	$sth = $dbh->prepare("SELECT line from elevtyperaw where elevtype_id=?");
	$sth->execute($elevtype_id) or die $DBI::errstr;
	my $linjer1  = $sth->rows;
	while( my @tmparr1 = $sth->fetchrow_array() ) {
		$tmparr1[0] =~ /^'(.*)'$/; #Strip of quotes '' from DB
		push(@{$elev_ref}, $1);
	}
	return($linjer1);
}
# Oprettet fag i tabel fag hvis det ikke eksisterer
sub create_fag($$) {
	my ($fagnr, $fagnavn) = @_;
	my $i;
	$sth = $dbh->prepare("SELECT fag_id FROM fag WHERE fagnr = ?");
	$sth->execute($fagnr) or die $DBI::errstr;
	$i  = $sth->rows;
	if ( $i == 0 ) {	#Hvis fagnr ikke eksisterer
		 $sth = $dbh->prepare("INSERT INTO fag
			(fagnr, fagnavn) values
			(?,?)");
		$sth->execute($fagnr, $fagnavn) or die $DBI::errstr;
	} else {            #Hvis fagnr eksisterer - check alt er ens
		$sth = $dbh->prepare("SELECT * FROM fag WHERE fagnr = ?");
		$sth->execute($fagnr) or die $DBI::errstr;
		$i  = $sth->rows;
		if ( $i >= 1 ) {	# Kan kun eksistere en gang!!
			printf("FAG %i eksisterer %i gange. ",$fagnr,$i); # Lav kun hvis problem
			return();
		} else { # Check ens
			my @tmparr2 =  $sth->fetchrow_array();
			if (($tmparr2[1] != $fagnr   ) || 
				($tmparr2[2] ne $fagnavn ) ) {
				printf("FAG %i eksisterer har to forskellige entries.\n",$fagnr); # Lav kun hvis problem
				printf("tmp: [%s] sub: [%s]\n", $tmparr2[1], $fagnr);
				printf("tmp: [%s] sub: [%s]\n", $tmparr2[2], $fagnavn);
				# Lav kun uddybende printf hvis problem
				#return;
			} 

		}
	}
}



################################################################
# MAIN PROGRAM                                                 #
################################################################
#File taken from http://eud-adm.dk
my $ordning_id = shift;
#Get common conf from config file
my %cfg;
Config::Simple->import_from('./eud.conf', \%cfg) or die("Configfil kunne ikke indlæses");
#Database connection string
my $dsn = "DBI:$cfg{driver}:database=$cfg{database}:host=$cfg{host}";
# Liste over kendte liniestarter
# Ændringer i @known skal også laves i trin1.pl
# Dårlig men hurtig programmering. :-)
my @known = (
    ["<FAG   >",'^Fag:\s*'],
    ["<NIVEAU>",'^Niveau:\s*'],
    ["<VARIG >",'^Varighed:\s*'],
    ["<FAGKAT>",'^Fagkategori:\s*'],
    ["<TYPE  >",'^Bundet/Valgfri:\s*'],
    ["<FRA   >",'^Tilknytningsperiode:\s*'],
    ["<RESUL1>",'^Resultatform\(er\):\s*'],
    ["<RESUL2>-", '^ -\, '],
    ["<PINDST>",'^ Nr\.\s+Målpind.*'],
    ["<SAMLIN>",'^Elevtypesamling:\s*'],
    ["<AFKORT>",'^Afkortning:\s*'],       # Hører til praktikmål
    ["<OPRVAR>",'^Opr. varighed:\s*'],    # Hører til praktikmål
    ["<OVRIGE>",'^Øvrige\s*'],
    ["<COMMON>",'^Fag fælles for hovedforløb\s*'],
    ["<SVP   >",'^Afsluttende prøve\s*'],
    ["<PRK   >",'^Praktikmål\s*'],
    ["<SPCFAG>",'^Fag på specialet/\s*'],
    ["<KOMPET>",'^Kompetencemål\s*'],
    ["<GRUFAG>",'^Grundfag\s*'],
    ["<MUNEVA>",'Mundtlig evaluering,\s*']
    #Målepinde senere
);

my $fase=1;
printf("Fase %2i: Henter elevtype informationer.....................",$fase++);
#Temporary vars
my $tmp;
my @tmparr;
my %udd;
#To dimentionelt array der skal indeholde: 
#  [elevtype_id, antallinjer_i_raw]
my @elevtypesize;
#database handles
#my $dbh;
#my $sth;
$dbh = DBI->connect($dsn, $cfg{userid}, $cfg{password} ) or die $DBI::errstr;
#$dbh->{TraceLevel} = "1|SQL"; # DBI DEBUG
#Hent antallet af rows(linier) som hver eletyperaw fylder i databasen.
# Hvis antallet af linier er ens er der en chance for at de to elevtyper
# er ens og der sammenlignes linie for linie. Hvis de er ens sammenlægges
# elevtyperne for at simplificere og give overblik for brugeren af dataene.
$sth = $dbh->prepare("select elevtyperaw.elevtype_id,count(*) 
						from elevtyperaw inner join elevtype
						on elevtype.elevtype_id = elevtyperaw.elevtype_id
						where elevtype.ordning_id = ? group
						by  elevtyperaw.elevtype_id");
$sth->execute($ordning_id) or die $DBI::errstr;
$udd{'elevtypeantal'}  = $sth->rows;
while( @tmparr = $sth->fetchrow_array() ) {
	push(@elevtypesize, [@tmparr]);
}
printf("[OK]\n");
printf("Fase %2i: Sammenskriver elevtyper der er ens................",$fase++);
printf("[OK]\n");
for ( my $i=0; $i < (scalar @elevtypesize) ; $i++ ) {
	#printf("Elevtype %i har %i linjer\n",$elevtypesize[$i][0],$elevtypesize[$i][1]);
	for ( my $j=0; $j < (scalar @elevtypesize) ; $j++ ) {
		if ( $elevtypesize[$i][1] == $elevtypesize[$j][1] && $i < $j ) {
			#printf("--->[i] Elevtype %i har %i linjer\n",$elevtypesize[$i][0],$elevtypesize[$i][1]);
			#printf("--->[j] Elevtype %i har %i linjer\n",$elevtypesize[$j][0],$elevtypesize[$j][1]);
			my @elevtype1;
			my @elevtype2;
			elevtype_read(\@elevtype1,$elevtypesize[$i][0]);	
			elevtype_read(\@elevtype2,$elevtypesize[$j][0]);	
			my $cou;
			for ( $cou=0; $cou < $#elevtype1 && $elevtype1[$cou] eq $elevtype2[$cou]; $cou++){}
			if ( $cou == $#elevtype1 ) {
				my $type1;
				my $type2;
				$sth = $dbh->prepare("select samling from elevtype where elevtype_id = ?");
				$sth->execute($elevtypesize[$i][0]) or die $DBI::errstr;
				$type1 = $sth->fetchrow_array();
				$sth->execute($elevtypesize[$j][0]) or die $DBI::errstr; 
				$type2 = $sth->fetchrow_array();
				printf("Elevtype %s er ens med %s - sammenskrives\n",$type1,$type2); 
				my $newtype = sprintf("(%s) og (%s)",$type1,$type2);
				$sth = $dbh->prepare("update elevtype set samling = \"($type1) og ($type2) ens og sammenskrevet\" where elevtype_id=?");
				$sth->execute($elevtypesize[$i][0]) or die $DBI::errstr;
				$sth = $dbh->prepare("delete from elevtyperaw where elevtype_id=?");
				$sth->execute($elevtypesize[$j][0]) or die $DBI::errstr;
				$sth = $dbh->prepare("delete from elevtype where elevtype_id=?");
				$sth->execute($elevtypesize[$j][0]) or die $DBI::errstr;
			}
		}
	}
}
printf("Fase %2i: Henter elevtyper og opretter dem en af gangen.....",$fase++);
$sth = $dbh->prepare("SELECT elevtype_id,samling FROM elevtype WHERE ordning_id=?");
$sth->execute($ordning_id) or die $DBI::errstr;
my @elevtyper;
my @elev;
my $linjer2  = $sth->rows; #Er der i DBI en smartere måde at indlæse et array?
while( @tmparr = $sth->fetchrow_array() ) {
	push(@elevtyper, [@tmparr]);
}
printf("[OK]\n");

printf("Der er %i elevtyper\n", $#elevtyper);
for ( my $i=0; $i < (scalar @elevtyper) ; $i++ ) {
	my $fasetxt = sprintf( "Fase %2i: ", $fase++ );
	$fasetxt = $fasetxt . $elevtyper[$i][1];
	printf( "%s", pad( $fasetxt, '.', 59 ) );	
	elevtype_create($elevtyper[$i][0]);  # Do it all
	#elevtype_read(\@elev,$elevtyper[$i][0]);	
	#printf("Der er %i linier\n",$#elev);
	#printf("Der er %i navn %s\n",$elevtyper[$i][0],$elevtyper[$i][1]);
	printf("[OK]\n");
}


printf("Henter alle fag\n");
my $sth5;
$sth5 = $dbh->prepare("SELECT line as fag FROM elevtyperaw WHERE line LIKE ?");
$sth5->execute("\'<FAG   >%") or die $DBI::errstr;
my $s = 0;
while(my $row = $sth5->fetchrow_array){
    my ($fag_name, $fag_id);

    if($row  =~ /(\D*[']$)/){
        $fag_name = $1;
    }else{
        $fag_name = "";
    }
    if($row  =~ /(\d{4,5})/){
        $fag_id = $1;
    }else{
        $fag_id = "";
    }

    $fag_name = substr($fag_name, 0, length($fag_name) - 1);
    if(length $fag_id > 0 && length $fag_name > 0){
        #create_fag($fag_id, $fag_name);
    }
    $s = $s + 1;
    #printf("Fase %2i: Opretter fag og faginstanser......................",$fase++);
    #printf("[OK]\n");
}

printf("Getting data");
$sth5 = $dbh->prepare("SELECT * FROM elevtyperaw");
$sth5->execute() or die $DBI::errstr;

my $fagArray = ();
my $tmpArray = ();
#my @row1 = [];
#while($row1 = $sth5->fetchrow_arrayref){
    #printf ($row1->[1]);
    #push $row1->[1], $tmpArray;
#    if($row1->[1] =~ /[<FAG   >]/){
#        push($fagArray, $row1);
#    }
#}
#printf($fagArray);
exit(1);
# Sammenlign elevtyger fag. Er der ens elevtyper skrives de sammen

#sub elevtype_read {
#	my $elev_ref = shift;
#	my $elevtype_id = shift;
#$sth = $dbh->prepare("SELECT line from elevtyperaw where elevtype_id=?");
#$sth->execute($elevtype_id[0]) or die $DBI::errstr;
#$udd{'linier'}  = $sth->rows;
my @doc;
#while( my @tmparr = $sth->fetchrow_array() ) {
#	push(@doc, $tmparr[0]);
#}
#if ( $udd{'linier'} != $#doc+1 ) {
# print("Antal linier indlæst passer ikke");
# exit(1);
#}
elevtype_read(\@doc,1);

=for comment
I en elevtype er der "Fag fælles for hovedforløb" (Tag <COMMON>) og specialer <SPCFAG>
<COMMON> ligges under alle <SPCFAG> og har ikke eget område.
=cut

for (my $i=0; $i<=$#doc; $i++) {
	printf("%5i: %s\n",$i,$doc[$i]);
}
$sth->finish;
$dbh->disconnect;

# select elevtype_id from elevtype where ordning_id=1;
#  select samling from elevtype where ordning_id=1 and elevtype_id=1;
# select line from elevtyperaw where elevtype_id=1;
#select elevtyperaw.elevtype_id,elevtype.ordning_id,count(*) from elevtyperaw inner join elevtype on elevtype.elevtype_id = elevtyperaw.elevtype_id where elevtype.ordning_id = 1 group by  elevtyperaw.elevtype_id;
#Specific
#select elevtyperaw.elevtype_id,count(*) from elevtyperaw inner join elevtype on elevtype.elevtype_id = elevtyperaw.elevtype_id where elevtype.ordning_id = 1 group by  elevtyperaw.elevtype_id;



