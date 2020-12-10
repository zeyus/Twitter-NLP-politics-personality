library(tidyverse)
library(quanteda)
library(readtext)
# prepare mapping and correlation data
cor_map <- read_csv("data/LIWC/liwc_cor_map.csv", col_types = list(
  col_character(),
  col_double(),
  col_double(),
  col_double(),
  col_double(),
  col_double(),
  col_double(),
  col_double(),
  col_character()
))


liwc_dict <- quanteda::dictionary(
  file = "data/LIWC/LIWC2015.Dictionary.English.2020.12.09.96630.dic",
  format = "LIWC")

### Create a corpus
# In this case, from a json - we can use any and specify content / text field

## This would grop the text based on the twitter username
# corpus_tweets <- corpus(
#   readtext("data/tweets_to_x/tweets_to_rustyrockets_fixed.json",
#   textfield = "tweet",
#   docid_field = "username"))

# group by tweet language
# corpus_tweets <- corpus(
#   readtext("data/tweets_to_x/tweets_to_rustyrockets_fixed.json",
#   text_field = "tweet"))
# only keep english
#corpus_tweets <- corpus_subset(corpus_tweets, language == "en")
# Create a document-feature matrix to map the LIWC dictionary
# dfm_tweets <- dfm(
#   corpus_tweets,
#   groups = "language",
#   dictionary = liwc_dict,
#   verbose = TRUE)

# corpus_tweets <- corpus(
#   readtext("data/tweet_w_big5/turbotobias_tweets.csv",
#   text_field = "text"))
# corpus_tweets

# summary(corpus_tweets, 5)
# # Create a document-feature matrix to map the LIWC dictionary
# dfm_tweets <- dfm(
#   corpus_tweets,
#   groups = "username",
#   dictionary = liwc_dict,
#   verbose = TRUE)


# group by tweet language
corpus_tweets <- corpus(
  readtext("data/tweet_w_big5/zachari_all_tweets_no_rt_fixed.json",
  text_field = "tweet"))

# Create a document-feature matrix to map the LIWC dictionary
dfm_tweets <- dfm(
  corpus_tweets,
  groups = "username",
  dictionary = liwc_dict,
  verbose = TRUE)


# should have one row only - 'en'
dfm_tweets

# Now for the fun
# weighted document freaquency: docfreq()
# Frequency of feature featfreq()

df_tweets <- as.data.frame(dfm_tweets)
#df_tweets <- select(df_tweets, -document)
df_tweets <- as.data.frame(t(df_tweets))
df_tweets$LIWC_Cat <- row.names(df_tweets)
names(df_tweets) <- c("Freq", "LIWC_Cat")
df_tweets <- df_tweets[-c(1),]

df_tweets$Freq <- as.numeric(df_tweets$Freq)

humans_freq <- sum(subset(df_tweets, LIWC_Cat %in% c("male", "female"))$Freq)
df_tweets <- rbind(df_tweets, humans = c(humans_freq, "humans"))
df_tweets$Freq <- as.numeric(df_tweets$Freq)
## Remove these categories
removed_cats <- c("adj",
"compare",
"interrog",
"drives",
"netspeak",
"informal",
"affiliation",
"power",
"reward",
"risk",
"conj",
"differ",
"male",
"female")

df_tweets <- df_tweets[!df_tweets$LIWC_Cat %in% removed_cats, ]

df_tweets$rel_freq <- with(df_tweets, Freq/sum(Freq))
sum(df_tweets$rel_freq)

df_tweets <- inner_join(df_tweets, cor_map)
df_tweets <- df_tweets %>%
  mutate(gender_scr = rel_freq * gender) %>%
  mutate(age_scr = rel_freq * age) %>%
  mutate(extraversion_scr = rel_freq * extraversion) %>%
  mutate(agree_scr = rel_freq * agreeableness) %>%
  mutate(conc_scr = rel_freq * conscientiousness) %>%
  mutate(neuroticism_scr = rel_freq * neuroticism) %>%
  mutate(openness_scr = rel_freq * openness)


round(colSums(Filter(is.numeric, df_tweets), na.rm = TRUE), 3)

# write_csv(df_tweets, "data/tweet_w_big5/zachari_assess.csv")
