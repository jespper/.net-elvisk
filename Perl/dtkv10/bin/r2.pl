#!/usr/bin/perl
#require "r1.pl";
#use r1;
use Acme::Include;
my @known2 = (
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
);


printf("A: %s\n",$known[1][0]);
print @known;
printf("Rows: %i, col: %i\n", scalar @known, scalar @{$known[0]});
printf("Rows: %i, col: %i\n", scalar @known2, scalar @{$known2[0]});
