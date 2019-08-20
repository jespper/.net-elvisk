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
databasen til viderebehandling i næste trin
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
#if ( !defined($infile) ) {
#    die("der skal angives en PDF file som input fra www.eud-adm.dk\n");
#}
#if ( !-r $infile ) { die("Kan ikke læse inputfil.. $infile\n") }
#my $rawfile = '../data/fagraw.leg';

#Get common conf from config file
my %cfg;
Config::Simple->import_from( './eud.conf', \%cfg )
  or die("Configfil kunne ikke indlæses");

#Database connection string
my $dsn  = "DBI:$cfg{driver}:database=$cfg{database}:host=$cfg{host}";
my $fase = 1;
printf( "Fase %2i: Oversætter PDF til text...........................",
    $fase++ );
#if ( system("pdftotext -layout '$infile' $rawfile 2>/dev/null") ) {
#    die("PDF fil kunne ikke oversættes til tekst ($infile)\n");
#}

open INFILE, '../data/of.txt' or die "Kan ikke åbne filen";
my $line;
my @doc;
my %udd;

#Temporary vars
my $tmp;
my @tmparr;

# Kopier raw ascii  til array
while ( defined( $line = <INFILE> ) ) {
    push( @doc, $line );
}
close(INFILE);
#goto label1;
my @fag;
my $j;
my $fagnr;
my $fagnavn;
	my $var;
	my $var2;
	my $flag=0;
	my $cou=0;
for ( my $i=0; $i<$#doc; $i++) {
	if ( $doc[$i] =~ /<OPRVAR>(.+)/ ) {
		$var=$1;
		$flag=1;
		$cou++;
	}
	if ( $doc[$i] =~ /<VARIG >(.+)/ ) {
		my $var2=$1;
		if ( $flag == 1 ) {
			if ( $var ne $var2 ) {
				printf("%3i: var=[%s] - var2=[%s]\n", $cou, $var, $var2);
			}
			$flag=0;
		}
	}
}
__END__
	if ( $doc[$i] =~ /<FAG   >(\d+)\s+(.+)/ ) {
		$fagnr=$1;
		$fagnavn=$2;
		for ( $j=0; $j <= $#fag; $j++ ) {
			if ( $fag[$j][0] == $fagnr ) {
				$fag[$j][2]++;
				last;
			}
		}	
		if ( $j > $#fag ) {
			push(@fag,[$fagnr,$fagnavn,1]);
		 }
	}
}
#Ii
for ( my $i=0; $i<$#fag; $i++) {
	printf("Antal: %2i - Fagnr.: %6i fag: %s\n",$fag[$i][2],$fag[$i][0],$fag[$i][1] );		
}
