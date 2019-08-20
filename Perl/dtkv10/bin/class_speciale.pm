#!/usr/bin/perl
use strict;
use warnings;
package class_speciale;
use Moose;
#use MooseX::AttributeHelpers;

has 'resultat' => (
    traits => ['Array'],
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub {[] },
    auto_deref => 1,
    handles => {
        add_resultat => 'push'
    },
);

has 'speciale' => (
  is  => 'rw',
  isa => 'Str',
);

has 'niveau' => (
  is  => 'rw',
  isa => 'Str',
);

has 'fagkat' => (
  is  => 'rw',
  isa => 'Str',
);
has 'fagtype' => (
  is  => 'rw',
  isa => 'Str',
);

sub wikiV8 {
  my $self = shift;
  my $text;
  $text = "{{Infobox specialeV8\n";
  if ( $self->speciale() =~ /Hoved/ ) {
    $text = $text . sprintf " | speciale   =  Fællesfag for hovedforløb\n";
  } else {
    $text = $text . sprintf " | speciale   = %s\n",$self->speciale();
  }
 $text = $text . sprintf " | fagkat     = [[%sV8|%s]]\n",$self->fagkat(),$self->fagkat();
 $text = $text . sprintf " | fagtype    = [[%sV8|%s]]\n",$self->fagtype(),$self->fagtype();
 $text = $text . sprintf " | niveau     = [[%sV8|%s]]\n",$self->niveau(),$self->niveau();

  my @tmpres = $self->resultat;
  for ( my $i = 0 ; $i <= $#tmpres ; $i++) {
   $text = $text . sprintf " | karakter%i  = %s\n",$i+1,$tmpres[$i];
  }
  $text = $text . sprintf "}}\n";
  return($text);
}
sub BUILD {
   	#print "Building Speciale\n";
   }
sub DEMOLISH {
   	#print "Demolishing Speciale\n";
   }
1;


