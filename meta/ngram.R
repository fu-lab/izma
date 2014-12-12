library(dplyr)

kpv.corpus %>% select(Session_name, Speaker, Token, Digram, Trigram)

kpv.corpus

# Digrams

kpv.corpus %>%
        select(Speaker, Token, Digram) %>% 
        filter(! grepl(".?[[:punct:]].?", Digram)) %>%
        count(Digram) %>%
        arrange(desc(n)) %>%
        head(100)

kpv.corpus %>%
        select(Token) %>%
        filter(! grepl(".?[[:punct:]].?", Token)) %>%
        count(Token) %>%
        arrange(desc(n)) %>%
        head(50)

# Trigrams

kpv.corpus %>%
        select(Speaker, Token, Trigram) %>% 
        filter(! grepl(".?[[:punct:]].?", Trigram)) %>%
        count(Trigram) %>%
        arrange(desc(n)) %>%
        head(100)

# Вылын

kpv.corpus %>%
        select(Speaker, Token, Digram) %>% 
        filter( grepl(".+вылын$", Digram)) %>%
        count(Digram) %>%
        arrange(desc(n)) %>%
        head(30)

# вӧлі *ма

kpv.corpus %>%
        select(Speaker, Token, ngram) %>%
        filter( grepl("^вӧлі.+{2}(ӧ|э)м(а)?(ӧ|э)?(сь)?$", ngram)) %>%
        head(30)

# -ӧмаӧсь

partis.types <- kpv.corpus %>%
        select(Speaker, Token) %>%
        filter( grepl(".+(ӧ|э)м[^ы^и]+(сь)+$", Token)) %>%
        filter(! grepl("\bэмесь\b", Token))


partis.types

partis.types$Type <- partis.types$Token
partis.types$Type <- gsub("(.+)((м)(.){1,2}сь$)", "\\2", partis.types$Type, perl = TRUE)


partis.types

partis.types %>% count(Type)

kpv.corpus

partis.types %>% count(Type)

# ext.partis

