# Liste over kendte liniestarter
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
);
1;
