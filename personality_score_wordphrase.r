library("easystats")
library(tidyverse)
library(quanteda)
library(readtext)
library(reshape2)


dimensions <- c(
  "neuroticism",
  "extraversion",
  "openness",
  "agreeableness",
  "conscientiousness",
  "gender",
  "age"
)
score_types <- c(
  "z_freq",
  "zr_freq"
  # "norm_freq",
  # "rel_freq"
)
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

blah_blah2 <- function(dimension, df, score_type) {
  sum(df[, score_type] * df[, dimension], na.rm = TRUE)
}

blah_blah <- function(score_type, df, dimensions) {
  result <- sapply(dimensions, blah_blah2, df = df, score_type = score_type, simplify = "array")
  t(as.data.frame(result))
}



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

# # group by tweet language
# corpus_tweets <- corpus(
#   readtext("data/tweets_to_x/tweets_to_SamHarrisOrg_fixed.json",
#   text_field = "tweet"))
# # only keep english
# corpus_tweets <- corpus_subset(corpus_tweets, language == "en")
# # Create a document-feature matrix to map the LIWC dictionary
# dfm_tweets <- dfm(
#   corpus_tweets,
#   groups = "language",
#   dictionary = liwc_dict,
#   verbose = TRUE)

#### CSV FROM ALEKS
# corpus_tweets <- corpus(
#   readtext("data/follower_tweets/xenopraxis_tweets.csv",
#   text_field = "text"))


#### JSON FROM TWINT
# group by tweet language
corpus_tweets <- corpus(
  readtext("data/from_follower_to_influencer/xenopraxis_at_BenShapiro_fixed.json",
  text_field = "tweet"))

# Create a document-feature matrix to map the LIWC dictionary
dfm_tweets <- dfm(
  corpus_tweets,
  groups = "username",
  dictionary = liwc_dict,
  verbose = TRUE)



df_tweets <- convert(t(dfm_tweets), to = "data.frame")
names(df_tweets) <- c("LIWC_Cat", "Freq")


humans_freq <- sum(subset(df_tweets, LIWC_Cat %in% c("male", "female"))$Freq)
df_tweets <- df_tweets %>%
  bind_rows(tibble(LIWC_Cat = "humans", Freq = humans_freq))


df_tweets <- df_tweets[!df_tweets$LIWC_Cat %in% removed_cats, ]
df_tweets$z_freq <- effectsize::standardize(df_tweets$Freq)
df_tweets$zr_freq <- effectsize::standardize(df_tweets$Freq, robust = TRUE)
df_tweets$norm_freq <- effectsize::normalize(df_tweets$Freq)

df_tweets$rel_freq <- with(df_tweets, Freq/sum(Freq))

df_tweets <- inner_join(df_tweets, cor_map)

summary_scores <- sapply(score_types, blah_blah, df = df_tweets, dimensions = dimensions, simplify = "list")

summary_scores <- as.data.frame(summary_scores, row.names = dimensions)

summary_scores$dimension <- rownames(summary_scores)

summary_scores.molten <- melt( summary_scores, id.vars="dimension", value.name="Freq", variable.name="Method" )


summary_scores.molten$dimension <- factor(summary_scores.molten$dimension, levels = dimensions)

summary_scores.molten %>% ggplot(aes(x = dimension, y = Freq, fill = Method)) +
  geom_bar(position = "dodge", stat = "identity") +
  theme(text = element_text(size = 20)) +
  geom_text(aes(label = round(Freq, 3)), vjust = -0.2, position = "dodge")

summary_scores.molten %>% ggplot(aes(x = dimension, y = Freq, fill = Method)) +
  geom_bar(position = "identity", stat = "identity", alpha = .3) +
  theme(text = element_text(size = 20)) +
  geom_text(aes(label = round(Freq, 3)), vjust = -0.2)






# df_tweets <- df_tweets %>%
#   mutate(gender_scr = rel_freq * gender) %>%
#   mutate(age_scr = rel_freq * age) %>%
#   mutate(extraversion_scr = rel_freq * extraversion) %>%
#   mutate(agree_scr = rel_freq * agreeableness) %>%
#   mutate(conc_scr = rel_freq * conscientiousness) %>%
#   mutate(neuroticism_scr = rel_freq * neuroticism) %>%
#   mutate(openness_scr = rel_freq * openness)

# round(colSums(Filter(is.numeric, df_tweets), na.rm = TRUE), 3)

# plot_dimensions(df_tweets)
# write_csv(df_tweets, "data/tweet_w_big5/zachari_assess.csv")

