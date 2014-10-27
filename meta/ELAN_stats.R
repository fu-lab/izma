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
kpv_meta <- tbl_dt(kpv_meta)

kpv_clean <- kpv_meta %>%
        subset(! Word %in% c(",", ".", ":", "", "-", ";", "!", "?", "…", '"', "(", ")", "~", "???") ) %>%
        subset(! attr.foreign %in% "TRUE" ) %>%
        tbl_dt()


kpv_clean

library(dplyr)
library(ggplot2)

kpv_meta$Age <- kpv_meta$Rec.year - kpv_meta$Birthyear

View(kpv_meta)

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
        group_by(Speaker, Filename, Word, Sex) %>%
        tally(sort = TRUE) %>%
        group_by(Sex) %>%
        tally(sort = TRUE)

# Это - сколко словы у нас естъ из мужины и из женжины
ggplot(kpv_clean, aes(x=Sex, fill=Sex)) + geom_histogram(alpha=0.5) +
        ggsave(file="токены_для_роды.png")

# Это - сколко словы из какой возростов, ну, с год рождения, здесь свет - он файл.
ggplot(kpv_clean, aes(x=Birthyear, fill=Filename)) + 
        geom_histogram(alpha=0.5) + 
        theme(legend.position="none") +
        ggsave(file="токены_для_год_рождении.png")

# Это об возростов
ggplot(kpv_clean, aes(x=Age, fill=Filename)) + 
        geom_histogram(alpha=0.4) + 
        theme(legend.position="none") +
        ggsave(file="токены_для_возростов.png")