# Смысль в этот скирпт есть посмортить автоматический статистики из ELAN файлов.
# Сколько слов, сколько дргуие формы и дальше. Idea of this script is to analyse
# from ELAN fails different statistics. How many tokens, how many word forms
# etc. Мӧвп тайӧ скриптын петкӧдлыны неуна статистика ELAN корпуссянь. Кымын
# кыв, кымын торъя формасӧ исв.

# rm(list = ls())

setwd("~niko/Desktop/github/data/izma/meta")

# These two scripts read in the ELAN files and the metadata. However, for
# privacy reason all metadata is not within GitHub folders, but outside it.

source("./../ELAN2R.R")
source("kpv_meta.R")

kpv_meta <- merge(kpv_corpus, kpv_corpus_meta)



library(dplyr)

kpv_words <- kpv_meta %>%
        subset(! Word %in% c(",", ".", ":", "", "-", ";", "!", "?", "…", '"', "(", ")", "~", "???") ) %>%
        subset(! attr.foreign %in% "TRUE" ) %>%
        group_by(Word) %>%
        tally(sort = TRUE)

kpv_tokens_per_speaker <- kpv_meta %>%
        subset(! Word %in% c(",", ".", ":", "", "-", ";", "!", "?", "…", '"', "(", ")", "~", "???") ) %>%
        subset(! attr.foreign %in% "TRUE" ) %>%
        group_by(Speaker, Filename, Word) %>%
        tally(sort = TRUE) %>%
        group_by(Speaker, Filename) %>%
        tally(sort = TRUE)

kpv_tokens_per_sex  <- kpv_meta %>%
        subset(! Word %in% c(",", ".", ":", "", "-", ";", "!", "?", "…", '"', "(", ")", "~", "???") ) %>%
        subset(! attr.foreign %in% "TRUE" ) %>%
        group_by(Speaker, Filename, Word) %>%
        tally(sort = TRUE) %>%
        group_by(Speaker, Filename) %>%
        tally(sort = TRUE)