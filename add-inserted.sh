#!/bin/sh

sed -r 's/$/ /g' | tr -s '\t ' ' ' |
    sed -r 's/([^e]) CapMisc /\1 Ins(CapMisc) /g' |
    sed -r 's/([^e]) CapMiscExt/\1 Ins(CapMiscExt)/g' |
    sed -r 's/([^e]) CapWord /\1 Ins(CapWord) /g' |
    sed -r 's/([^e]) CapName /\1 Ins(CapName) /g' |
    sed -r 's/([^e]) Abbr /\1 Ins(Abbr) /g' |
    sed -r 's/([^e]) CapNameGen /\1 Ins(CapNameGen) /g' |
    sed -r 's/([^e]) CapNameNom /\1 Ins(CapNameNom) /g' |
    sed -r 's/([^e]) AndOfThe /\1 Ins(AndOfThe) /g' |
    sed -r 's/([^e]) PropGeoGen /\1 Ins(PropGeoGen) /g' |
    sed -r 's/([^e]) PropGen /\1 Ins(PropGen) /g' |
    sed -r 's/([^e]) (Prop[FL][A-Za-z]+) /\1 Ins(\2) /g' |
    sed -r 's/([^e]) (PropOrg[A-Za-z]+) /\1 Ins(\2) /g' |
    sed -r 's/([^e]) DashExt /\1 Ins(DashExt) /g' |
    sed -r 's/([^e]) InQuotes /\1 Ins(InQuotes) /g' |
    sed -r 's/([^e]) CapNameGenNSB /\1 Ins(CapNameGenNSB) /g' |
    sed -r 's/([^e]) CapNounGenNSB /\1 Ins(CapNounGenNSB) /g' 
