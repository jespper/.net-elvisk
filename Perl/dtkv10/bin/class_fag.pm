#!/usr/bin/perl
use strict;
use warnings;
package class_fag;
use Moose;
#use MooseX::AttributeHelpers; #Deprecated

my $debug1=0;

#Status = 0 : Only V8-2011
#Status = 1 : Common V8-2010 and V8-2011
#Status = 2 : Only V8-2010
has 'status' => (
  is      => 'rw',
  isa     => 'Int',
  default => 0
#  default => sub { 0 },
);
has 'fagnr' => (
  is  => 'rw',
  isa => 'Str',
  default => ' ',
);

has 'fagnavn' => (
  is  	   => 'ro',
  isa 	   => 'Str',
  required => 1

);

has 'varighed' => (
  is  => 'rw',
  isa => 'Str',
  default => '0,0',
);

has 'gyldig' => (
  is  => 'rw',
  isa => 'Str',
  default => ' ',
);
has 'oprvar' => (
  is  => 'rw',
  isa => 'Str',
  default => ' ',
);
has 'afkort' => (
  is  => 'rw',
  isa => 'Str',
  default => ' ',
);

has 'navn' => (
  is  => 'rw',
  isa => 'Str',
  default => ' ',
);

has 'pind' => (
    traits => ['Array'],
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub {[] },
    auto_deref => 1,
    handles => {
	add_pind  => 'push'
    },

);
has 'speciale' => (
    traits => ['Array'],
    is => 'rw',
    isa => 'ArrayRef[Object]',
    default => sub {[] },
    auto_deref => 1,
    handles => {
        add_speciale => 'push'
    },
);

sub wiki {

  my $text;
  my $self = shift;
  $text =  "{{Infobox fagV7\n";
  $text = $text . sprintf " | fagnr      = %s\n", $self->fagnr();
  $text = $text . sprintf " | fagnavn    = %s\n", $self->fagnavn();
  $text = $text . sprintf " | varighed   = %s\n", $self->varighed();
  $text = $text . sprintf " | gyldig     = %s\n", $self->gyldig();
if ($debug1) { print "Wiki:", $self->fagnr()," ", $self->fagnavn()," til ",$self->navn()," målepinde: "; }
  my @pinde = $self->pind;
  my $m;
  for ($m=0 ; $m <= $#pinde ; $m++) {
    $text = $text . sprintf " | målpind%i  = %s\n", $m+1, $pinde[$m];
    if ($debug1) {if ($m > 50) { die "Der er mere end 50 målepinde - fagnr: ",$self->fagnr()," i ",$self->navn,"\n"; } }
}
  
 if ($debug1) {   print "$m\n"; }
  # Opret Tilknyttede specialer felt
   my @specialer;
 $text = $text . sprintf " | tilknyttet = ";
   if ( $self->fagnavn() =~ /Valgfag/ ) {
    $text = $text . sprintf "[[%sV7|%s]]",$self->navn,$self->navn;
  }
  if ( $self->navn =~ /Hoved/ ) {
    $text = $text . sprintf "[[IT-SupporterV7|IT-Supporter]] [[DatateknikerV7|Datatekniker]] [[KontorserviceteknikerV7|Kontorservicetekniker]] [[TeleinstallationsteknikerV7|Teleinstallationstekniker]] [[TelesystemteknikerV7|Telesystemtekniker]]";
  } else {
     @specialer = $self->speciale();
     for (my $i=0 ; $i <= $#specialer ; $i++ ) {
       $text = $text . sprintf " [[%sV7|%s]]",$specialer[$i]->speciale(),$specialer[$i]->speciale();
     }
  }
 $text = $text . sprintf "\n";
 $text = $text . sprintf "}}\n";
  @specialer = $self->speciale();
  for (my $i=0 ; $i <= $#specialer ; $i++ ) {
    $text = $text . $specialer[$i]->wikiV8(); #HeTh /211010 
  }
 
# Translate æøåÆØÅ to UTF8 (Hvis det ikke allerede er)
#Fx. ordet målpind til skabelon er lavet med windows å :-( 
$text =~ s/æ/\303\246/g;
$text =~ s/ø/\303\270/g;
$text =~ s/å/\303\245/g;
$text =~ s/Æ/\303\206/g;
$text =~ s/Ø/\303\230/g;
$text =~ s/Å/\303\205/g;
$text =~ s/\302\277/'/g; #De anvender forkert UTF pling (') hos UVM
#$text =~ s/\//\\\//g;
#$text =~ s/\+/\\+/g;
 return($text);
}
# Version 8 to Wiki
sub wikiV8 {

  my $text;
  my $self = shift;
  $text =  "{{Infobox fag\n";
  $text = $text . sprintf " | fagnr      = %s\n", $self->fagnr();
  $text = $text . sprintf " | fagnavn    = %s\n", $self->fagnavn();
  $text = $text . sprintf " | varighed   = %s\n", $self->varighed();
  $text = $text . sprintf " | gyldig     = %s\n", $self->gyldig();
if ($debug1) { print "Wiki:", $self->fagnr()," ", $self->fagnavn()," til ",$self->navn()," målepinde: "; }
  my @pinde = $self->pind;
  my $m;
  for ($m=0 ; $m <= $#pinde ; $m++) {
    $text = $text . sprintf " | målpind%i  = %s\n", $m+1, $pinde[$m];
    #if ($debug1) {if ($i > 50) { print "Der er mere end 50 målepinde";
    #  print "fagnr: ",$self->fagnr()," i ",$self->navn,"\n"; } else {
    #  die("Arrghhhhh");}}
  }
if ($debug1) {   print "$m\n"; }
  # Opret Tilknyttede specialer felt
   my @specialer;
 $text = $text . sprintf " | tilknyttetV8 = ";
   if ( $self->fagnavn() =~ /Valgfag/ ) {
    $text = $text . sprintf "[[%sV7|%s]]",$self->navn,$self->navn;
  }
  if ( $self->navn =~ /Hoved/ ) {
    $text = $text . sprintf("[[IT-SupporterV8|IT-Supporter]] " .
                       "[[Datatekniker-programmeringV8|Datatekniker-programmering]] " .
                       "[[Datatekniker-infrastrukturV8|Datatekniker-infrastruktur]] " .
                       "[[TeleinstallationsteknikerV8|Teleinstallationstekniker]] " .
                       "[[TelesystemteknikerV8|Telesystemtekniker]]");
  } else {
     @specialer = $self->speciale();
     for (my $i=0 ; $i <= $#specialer ; $i++ ) {
       
       #-
       #Datatekniker uddannelsesnavn for langt forkorter det lidt
        if ( $specialer[$i]->speciale() =~/Datatekniker/) {
          if ($specialer[$i]->speciale() =~/infrastruktur/) {
            $text = $text . sprintf " [[Datatekniker-infrastrukturV8|Datatekniker-infrastruktur]] "; 
          }
          if ($specialer[$i]->speciale() =~/programmering/) {
            $text = $text . sprintf " [[Datatekniker-programmeringV8|Datatekniker-programmering]] "; 
          }
        } else {
          #IT-supporter eller tele
          $text = $text . sprintf " [[%sV8|%s]] ",$specialer[$i]->speciale(),$specialer[$i]->speciale();
        }
       #-
     }
  }
 $text = $text . sprintf "\n";
 $text = $text . sprintf "}}\n";
  @specialer = $self->speciale();
  for (my $i=0 ; $i <= $#specialer ; $i++ ) {
    $text = $text . $specialer[$i]->wikiV8();
  }
 # Translate æøåÆØÅ to UTF8
$text =~ s/æ/\303\246/g;
$text =~ s/ø/\303\270/g;
$text =~ s/å/\303\245/g;
$text =~ s/Æ/\303\206/g;
$text =~ s/Ø/\303\230/g;
$text =~ s/Å/\303\205/g;
$text =~ s/\302\277/"/g; #De anvender forkert UTF gåseøjne hos UVM
#$text =~ s/\//\\\//g;
#$text =~ s/\+/\\+/g;
 return($text);
}
sub BUILD {
    #print "Building fag\n";
}
sub DEMOLISH {
    #print "Demolising fag\n";
}
1;
