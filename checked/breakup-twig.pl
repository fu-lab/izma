#!/usr/bin/perl
#Sample usage from Mac Terminal: perl ELAN_kpv_UPA-CYR-twig.pl > test1.eaf
#You don't need to repeat the name of the file you start from as it is already on the first line.
binmode(STDOUT, ":utf8");
use strict;
use warnings;
use utf8;

use XML::Twig;

my %trans = (        
      "\."=> ' .',
      "\,"=> ' ,',
      "\!" => " !",
      "\:" => " :",
      "\(" => "( ",
      "\)" => " )",
      "???" => "???",
      "\?" => " ?",
      '"' => ' " ',
);

# Actual Translation Logic:
my @signs = sort {length($b) <=> length($a)} keys %trans;
@signs = map quotemeta($_), @signs;
my $re = join '|', @signs, '.'; 


XML::Twig->new( twig_roots => 
    {  q{TIER[@LINGUISTIC_TYPE_REF='orthT']/ANNOTATION/REF_ANNOTATION/ANNOTATION_VALUE}
          => sub { my $in= $_->text; #warn "called text: ", $_->text, "\n";
                   $in=~ s/($re)/exists($trans{$1}) ? $trans{$1} : $1/geo; 
                   $_->set_text( $in);
                   $_->print;
                 },
    },
       twig_print_outside_roots => 1,
               )
         ->parsefile('kpv_udo19660927EVV-2-18-my_fathers_stories.eaf');
