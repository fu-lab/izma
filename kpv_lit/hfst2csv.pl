#!/usr/bin/perl -w

# Sample usage should be just:

# perl hfst2csv.pl < kpv_lit19570000lytkin.txt > kpv_lit19570000lytkin.hfst

while (<>)

{

s/^\n$// ;
s/¶\t¶\+CLB\t0\.000000//g ;
s/(a\d+)\ta\d+\+\?\tinf(\n)/$1$2/g ;
s/(a\d+)\n/$1\t/g ;
s/(.+)\n/$1\t/g ;
#s/(a\d+)\t(.+)\t(.+)(\n)/$1\t$3$4/g ;
# What I do now is to take the two first tabs and save them as something else
#s/(a\d+)(\t)(.+)(\t)//g;

print ;
}