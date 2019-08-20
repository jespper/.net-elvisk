#!/usr/bin/perl

=for comment
Dette modul oversætter rå uddannelsesordning PDF fil fra eud-adm.dk
efter 2015. vælg: Hovedforløbet og alle specialetrin
                  Udvidet oversigt
                  Medtag resultatformer
                  Medtag målepinde
                  Alle elevtypesamlinger

Modulet opretter ordningen i databasen opdeler i elevtyper og
gemmer alle linier fra PDF'en der hører til elevtypen i 
databasens elevtyperaw til viderebehandling i næste trin
=cut

select(STDERR);
$| = 1;
select(STDOUT);
$| = 1;
use strict;
use warnings;
use lib '.';
use Storable;
use DBI;

#use utf8;
use Config::Simple;

# SUBS

#Konverter dato string fra DD-MM-YYYY til YYYY-MM-DD
sub sqldate {
    my $date = shift;
    $date =~ /(\d+)-(\d+)-(\d+)/;
    $date = "$3-$2-$1";
    return ($date);
}

#Padder en tekst streng $str med tegnet $padding
sub pad {
    my ( $str, $padding, $length ) = @_;

    my $pad_length = $length - length $str;
    $pad_length = 0 if $pad_length < 0;
    $padding x= $pad_length;
    $str . $padding;
}

sub usage {
    printf("$0 PDF-file\n");
    exit;
}
################################################################
# MAIN PROGRAM                                                 #
################################################################
#File taken from http://eud-adm.dk
my $infile = shift;
if ( !defined($infile) ) {
    die("der skal angives en PDF file som input fra www.eud-adm.dk\n");
}
if ( !-r $infile ) { die("Kan ikke læse inputfil.. $infile\n") }
my $rawfile = '../data/raw.txt';

#Get common conf from config file
my %cfg;
Config::Simple->import_from( './eud.conf', \%cfg )
  or die("Configfil kunne ikke indlæses");

#Database connection string
my $dsn  = "DBI:$cfg{driver}:database=$cfg{database}:host=$cfg{host}";
my $fase = 1;
printf( "Fase %2i: Oversætter PDF til text...........................",
    $fase++ );
if ( system("pdftotext -layout '$infile' $rawfile 2>/dev/null") ) {
    die("PDF fil kunne ikke oversættes til tekst ($infile)\n");
}

open INFILE, $rawfile or die "Kan ikke åbne $rawfile";
my $line;
my @doc;
my %udd;

#Temporary vars
my $tmp;
my @tmparr;

my $tmptype;

# Kopier raw ascii  til array
while ( defined( $line = <INFILE> ) ) {
    push( @doc, $line );
}
close(INFILE);
#goto label1;

for(my $i; $i < $#doc; $i++){
    #printf $i.": " . $doc[$i];

    if($doc[$i] =~ /Elevtypesamling:/){
        printf $i . ": " . $doc[$i];
        $tmptype = $';
        printf $tmptype;
    }
    if()
}

exit(1);

# Find fagretning og version
$doc[0] =~ /\s*(\S*.*$)/;
$udd{'udvalg'} = $1;
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    if ( $doc[$i] =~ /^Uddannelsesordning for \d+/ ) {
        $doc[$i] =~ /^Uddannelsesordning for (\d+) (.+) \(version (\d+)/;

        #$doc[$i] =~ /^Uddannelsesordning for (\d+).*/;# (.+ \()version (\d+)/;
        $udd{'ver'}     = $3;
        $udd{'ordning'} = $2;
        $udd{'nr'}      = $1;
        last;
    }
}
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    if ( $doc[$i] =~ /\s*Udskrevet den (\d+-\d+-\d+)/ ) {
        $udd{'udskrevet'} = sqldate($1);
        last;
    }
}

#Find antal sider
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    if ( $doc[$i] =~ /.+Side\s+\d+\saf\s(\S+)$/ ) {
        $udd{'sider'} = $1;

        #Fjern tusind adskiller fx. 1.234 sider til 1234
        $udd{'sider'} =~ tr/0123456789\./0123456789/d;
        last;
    }
}

# Find Versionsdato
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    if ( $doc[$i] =~ /^Bekendtgørelse om/ ) {
        $doc[$i] =~ /^Bekendtgørelse om (.+)\((\d+-\d+-\d+)\)/;
        $udd{'bekendt'} = $1;
        $udd{'revdato'} = sqldate($2);
        last;
    }
}
printf("[OK]\n");
printf( "  - Uddannelsesudvalg..: %s\n",  $udd{'udvalg'} );
printf( "  - Uddannelsesordning.: %s\n",  $udd{'ordning'} );
printf( "  - Bekendtgørelse.....: %s\n",  $udd{'bekendt'} );
printf( "  - Uddannelsesnummer .: %s\n",  $udd{'nr'} );
printf( "  - Uddannelsesversion.: %s\n",  $udd{'ver'} );
printf( "  - Revisionsdato......: %s\n",  $udd{'revdato'} );
printf( "  - Udskriftsdato......: %s\n",  $udd{'udskrevet'} );
printf( "  - Antal sider........: %s\n",  $udd{'sider'} );

#Er denne version allerede i databasen?
my $dbh;
my $sth;
$dbh = DBI->connect( $dsn, $cfg{userid}, $cfg{password} ) or die $DBI::errstr;

#$dbh->{TraceLevel} = "1|SQL"; # DBI DEBUG
$sth = $dbh->prepare(
    "SELECT ordning_id FROM ordning WHERE 
      (version=$udd{'ver'} AND ordning_nr=$udd{'nr'} AND
       revision_dato=\"$udd{'revdato'}\" AND
       antal_sider=$udd{'sider'})"
);
$sth->execute() or die $DBI::errstr;
my $kl = $sth->rows;
if ( $kl >= 1 ) {
    printf(
"Denne version er allerede i databasen - skal den inlæses igen? (Y/N) [N]: "
    );
    my $ANSWER = <STDIN>;
    chomp $ANSWER;    # Remove line ending
    if ( $ANSWER ne "Y" && $ANSWER ne 'y' ) {
        $sth->finish;
        $dbh->disconnect;
        print("Fejl: Stopper..............\n");
        exit(10);
    }
}
printf("\n\nEr ovenstående oplysninger korrekte?  (Y/N) [N]: ");
my $ANSWER = <STDIN>;
chomp $ANSWER;        # Remove line ending
if ( $ANSWER ne "Y" && $ANSWER ne 'y' ) {
    print("Fejl: Stopper..............\n");
    exit(1);
}

printf( "Fase %2i: Parser trin 1 (Fjernet sidehoveder)...............", $fase++ );
#
#Fjern øverste linier på hver side. Led efter <FF> (Sidehoved)
#Første side manuelt. (Der er ingen <FF>
my $REMOVE = 7;    #Antal linier der skal fjernes
splice( @doc, 0, $REMOVE );    #

# Fjern nedefra.
for ( my $i = $#doc ; $i >= 0 ; $i-- ) {
    if ( $doc[$i] =~ /\f/ ) {    # FF {
        splice( @doc, $i, $REMOVE );
    }
}
printf("[OK]\n");
printf( "Fase %2i: Parser trin 2 (Konverterer white space)...........",
    $fase++ );

#Fjern tomme linier, ekstra spaces, konverter tab(s) til en space
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    $doc[$i] =~ s/^\s+/ /;       # Fjern ekstra spaces i starten af linien
    chomp( $doc[$i] );
    if ( $doc[$i] !~ /^\s*$/ ) {    # Tomme liner fjernes
        $doc[$i] =~ s/\s+/ /g;      #Fjern tabs og spaces og indsæt en space
    }
    else {
        splice( @doc, $i, 1 );
        $i--;                       # Removed the line we are on
    }
}

printf("[OK]\n");

my $doc_lines=$#doc + 1; #Antal linjer skal være konstant nu
#label1:
printf( "Fase %2i: Parser trin 3 (Checker syntax) Trin 1.............",
    $fase++ );
open OF, ">../data/ofbefore.txt";
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    printf( OF "%s\n", $doc[$i] );
}
close OF;

# Liste over kendte liniestarter
# Ændringer i @known skal også laves i trin2.pl
# Dårlig men hurtig programmering. :-)
my @known = (
    ["<FAG   >",'^Fag:\s*'],
    ["<NIVEAU>",'^Niveau:\s*'],
    ["<VARIG >",'^Varighed:\s*'],
    ["<FAGKAT>",'^Fagkategori:\s*'],
    ["<TYPE  >",'^Bundet/Valgfri:\s*'],
    ["<FRA   >",'^Tilknytningsperiode:\s*'],
    ["<FRA   >",'^Tilknytningsperiode \s*'], # Kolon (:) ikke fra 08-2019?
    ["<RESUL1>",'^Resultatform\(er\):\s*'],
    ["<RESUL1>",'^Resultatform\(er\)\s*'],  # Kolon (:) ikke fra 08-2019?
    ["<RESUL2>-", '^ -\, '],
    ["<PINDST>",'^ Nr\.\s+Målpind.*'],
    ["<SAMLIN>",'^Elevtypesamling:\s*'],
    ["<AFKORT>",'^Afkortning:\s*'],       # Hører til praktikmål
    ["<OPRVAR>",'^Opr. varighed:\s*'],    # Hører til praktikmål
    ["<OVRIGE>",'^Øvrige\s*'],
    ["<COMMON>",'^Fag fælles for hovedforløb\s*'],
    ["<SVP   >",'^Afsluttende prøve\s*'],
    ["<PRK   >",'^Praktikmål\s*'],
    ["<SPCFAG>",'^Fag på specialet/trinnet\s*'],
    ["<KOMPET>",'^Kompetencemål\s*'],
    ["<GRUFAG>",'^Grundfag\s*'],
    ["<MUNEVA>",'Mundtlig evaluering,\s*']	
    #Målepinde senere
);
#Find linier der ikke matcher @known
#de må være fagspecialer, målepinde eller fejl i dokumentet
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    my $found = 0;
    my $j;
    for ( $j = 0 ; ( $j <= $#known ) && ( $found == 0 ) ; $j++ ) {

        if ( $doc[$i] =~ m/$known[$j][1]/ ) {

            #Målepinde kan have flere linier!!!!
            $found = 1;
			$doc[$i] =~ s/$known[$j][1]/$known[$j][0]/;
        }
	}
}
printf("[OK]\n");
printf( "Fase %2i: Parser trin 4 (Checker syntax) Trin 2.............",
 $fase++ );
# Resten af linerne der ikke starter med <.{6,}> må være målpinde
# Målepinde kan være i flere linier
my $pind = 0;
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
	if ( !($doc[$i] =~ /^<.{6}>/) ) {	#Målpinde har ikke <> tags
		#printf("Checker[%3i] %s \n",$i ,$doc[$i] );
		if ( $doc[$i] =~ / \d+/ ) {	# Indeholder tal er det første linie i målpind
			$pind=1; #Måske yderligere linier i målpind
			$doc[$i] =~ s/^ /<PIND  >/;
		}
		if ( ( $doc[$i] =~ / \D+/ ) && ( $pind==1 ) ) {
			$doc[$i] =~ s/^ /<PIND+ >/;
		} else {
			$pind = 0; #Mulilinje pind slut
		}
	}
}	
printf("[OK]\n");
#Sidste check - der skal være <> tags i alle linjer
printf( "Fase %2i: Parser trin 5 (Konsistens check)..................",
	$fase++);
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
	#DEBUG PIND - printf("Linie: %5i: |%s|\n", $i, $doc[$i]); #DEBUG HeTh
	if ( !($doc[$i] =~ /^<.{6}>/) ) {	#Målpinde har ikke <> tags
		printf("ERROR: Der mangler <> tags i linje %s\n", $i );
		exit(0);
	}
}
printf("[OK]\n");
printf( "Fase %2i: Skriver parset tekstfil til disk..................",
    $fase++ );
open OF, ">../data/of.txt";
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    printf( OF "%s\n", $doc[$i] );
}
close OF;
if ( $doc_lines != $#doc + 1) {
	printf("Antallet af linjer har ændret sig fra %i til %i", $doc_lines, $#doc + 1);	
	exit(8);
}
printf("[OK]\n");
printf( "Fase %2i: Opretter ordning i databasen......................",
    $fase++ );

#Build dsn
$dbh = DBI->connect( $dsn, $cfg{userid}, $cfg{password} ) or die $DBI::errstr;

#DEBUG $dbh->{TraceLevel} = "3|SQL|foo";

$sth = $dbh->prepare(
    "INSERT INTO ordning (ordning_id, bekendt,version,
                           dato, revision_dato, udskrevet, udvalg, 
                           ordning_nr, antal_sider)
                           values (NULL,\"$udd{'bekendt'}\",$udd{'ver'},
                           CURDATE(),\"$udd{'revdato'}\",\"$udd{'udskrevet'}\",\"$udd{'udvalg'}\",
                           $udd{'nr'}, $udd{'sider'})"
);
$sth->execute() or die $DBI::errstr;
printf("[OK]\n");
my $ordning_id = $dbh->{'mysql_insertid'};

#Find elevtypesamlinger <SAMLIN> - Se @known
for ( my $i = 0 ; $i <= $#doc ; $i++ ) {
    my $fasetxt = sprintf( "Fase %2i: Opretter elevtype ", $fase++ );
    if ( $doc[$i] =~ /^<SAMLIN>(.+)/ ) {

        #Elevtype navne er lidt forkerte i 1205 - ret dem til
        my $elevtype = $1;
        $elevtype =~ s/EUV 2/EUV2/;
        $elevtype =~ s/EUV 1og/EUV1 og/;
        $elevtype =~ s/ ta$/ talent/;
        $doc[$i] = $elevtype
          ;    #Skriv det rigtige tilbage (ved ikke om det skal bruges der)
        $fasetxt = $fasetxt . $elevtype;
        printf( "%s", pad( $fasetxt, '.', 59 ) );
        $sth = $dbh->prepare(
            "INSERT INTO elevtype (elevtype_id, ordning_id ,samling)
                                      values( NULL, $ordning_id, \"$elevtype\")"
        );
        $sth->execute() or die $DBI::errstr;
        my $elevtype_id = $dbh->{'mysql_insertid'};
        $i++;
        my @elevtypelines;
        while ( ( $i <= $#doc ) && ( $doc[$i] !~ /^<SAMLIN>/ ) ) {
            push( @elevtypelines, $dbh->quote( $doc[$i] ) );
            $i++;
        }
        $sth = $dbh->prepare(
            "INSERT INTO elevtyperaw (line_id, line, elevtype_id)
					      values ( NULL, ? , $elevtype_id)"
        );
        my $lines =
          $sth->execute_array( { ArrayStatus => \my @status }, \@elevtypelines )
          or die $DBI::errstr;
        if ( $lines != $#elevtypelines + 1 ) {
            printf( "ERROR: %i elevtypelines - %i lines inserted t database\n",
                $#elevtypelines + 1, $lines );
            exit(11);
        }
        printf("[OK]\n");

        $i--;
    }
}
$dbh->disconnect();
printf( "trin 1 overstået - ordningsnummer = %i\n", $ordning_id );
