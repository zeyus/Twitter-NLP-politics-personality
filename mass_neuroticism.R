library("easystats")
library(tidyverse)
library(quanteda)
library(readtext)
library(reshape2)

dimensions <- c(
  "neuroticism",
  "age",
  "gender"
)
score_types <- c(
  "z_freq"
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

process_user <- function(filename) {
  #### JSON FROM TWINT
  # group by tweet language
  corpus_tweets <- corpus(
    readtext(filename,
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

  df_tweets <- inner_join(df_tweets, cor_map)

  summary_scores <- sapply(
    score_types,
    blah_blah,
    df = df_tweets,
    dimensions = dimensions,
    simplify = "list")

  summary_scores <- as.data.frame(summary_scores, row.names = dimensions)

  summary_scores$dimension <- rownames(summary_scores)

  summary_scores$filename <- basename(filename)

  summary_scores

}

files <- Sys.glob("data/from_follower_to_influencer/*_at_BenShapiro_fixed.json")
files <- Sys.glob("data/all_tweets/*_fixed.json")
block_len <- 7
dflen <- length(files) * block_len
dim <- character(dflen)
freq <- numeric(dflen)
user <- character(dflen)


count <- 0
for (f in files) {
  count <- count + 1
  fist <- (count - 1) * block_len + 1
  anus <- count * block_len
  df <- process_user(f)

  dim[fist:anus] <- df$dimension
  freq[fist:anus] <- df$z_freq
  user[fist:anus] <- df$filename
}

summary_scores <- data.frame(dim, freq, user, stringsAsFactors = FALSE)

write_csv(
  summary_scores,
  "data/processed_neuroticism_all_tweets_influencers.csv")
# summary_scores.molten <- melt(
#   summary_scores,
#   id.vars = "dim",
#   value.name = "freq",
#   variable.name = "user")


# summary_scores.molten$dim <- factor(
#   summary_scores.molten$dim,
#   levels = dimensions)
#   summary_scores.molten

# summary_scores.molten %>% ggplot(aes(x = dim, y = freq, fill = user)) +
#   geom_bar(position = "dodge", stat = "identity") +
#   theme(text = element_text(size = 20)) +
#   geom_text(aes(label = round(freq, 3)), vjust = -0.2, position = "dodge")

# summary_scores.molten %>% ggplot(aes(x = dimension, y = Freq, fill = Method)) +
#   geom_bar(position = "identity", stat = "identity", alpha = .3) +
#   theme(text = element_text(size = 20)) +
#   geom_text(aes(label = round(Freq, 3)), vjust = -0.2)






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




##### part 3 not autorun

corpus_tweets <- corpus(
  readtext('pol_tweets_leaning.csv',
  text_field = "tweet"))

# Create a document-feature matrix to map the LIWC dictionary
dfm_tweets <- dfm(
  corpus_tweets,
  groups = c("username", "influencer_party"),
  dictionary = liwc_dict,
  verbose = TRUE)
head(dfm_tweets)
tl_tweets <- convert(dfm_tweets, "tripletlist")
df_tweets <- data.frame(
  username = tl_tweets$document,
  LIWC_Cat = tl_tweets$feature,
  Freq = tl_tweets$frequency)
head(df_tweets)

humans_freq <- df_tweets[(df_tweets$LIWC_Cat %in% c("male", "female")),] %>%
  group_by(username) %>%
  summarise(Freq = sum(Freq))
tail(humans_freq)
df_tweets <- df_tweets %>%
  bind_rows(tibble(LIWC_Cat = "humans", Freq = humans_freq$Freq, username = humans_freq$username))
tail(df_tweets)

df_tweets <- df_tweets[!df_tweets$LIWC_Cat %in% removed_cats, ]

df_tweets <- inner_join(df_tweets, cor_map)

df_tweets <- df_tweets %>% group_by(username) %>%
  effectsize::standardize(, select = "Freq", append = TRUE)

nrow(df_tweets)
tail(df_tweets)

df_tweets$neuroticism_score <- df_tweets$neuroticism * df_tweets$Freq_z
df_tweets$extraversion_score <- df_tweets$extraversion * df_tweets$Freq_z
df_tweets$agreeableness_score <- df_tweets$agreeableness * df_tweets$Freq_z
df_tweets$conscientiousness_score <- df_tweets$conscientiousness * df_tweets$Freq_z
df_tweets$openness_score <- df_tweets$openness * df_tweets$Freq_z
df_tweets$age_score <- df_tweets$age * df_tweets$Freq_z
df_tweets$gender_score <- df_tweets$gender * df_tweets$Freq_z
head(df_tweets$username)
name_party <- str_split(df_tweets$username, fixed("."), simplify = TRUE)
df_tweets$username <- name_party[, 1]
df_tweets$influencer_party <- name_party[, 2]
head(df_tweets$username)


df_userdata <- read_csv('pol_tweets_leaning.csv')

df_userdata <- df_userdata %>%
  distinct(username, .keep_all = TRUE) %>%
  select(c(username, party))


  
head(df_userdata)
df_tweets <- left_join(df_tweets, df_userdata, by = "username")
df_tweet_score <- df_tweets %>%
  group_by(username) %>%
  summarise(
    neuroticism_score = sum(neuroticism_score, na.rm = TRUE),
    party = party,
    influencer_party = influencer_party) %>%
  distinct(username, .keep_all = TRUE)
head(df_tweet_score)
summary(aov(neuroticism_score ~ party + influencer_party, data=df_tweet_score))

summary_values <-
  df_tweet_score %>%
  group_by(party, influencer_party) %>%
  summarise(
    n = n(),
    mean = mean(neuroticism_score),
    sd = sd(neuroticism_score),
    se = sd(neuroticism_score)/sqrt(length(neuroticism_score)))
summary_values

df_tweet_score %>%
  ggplot(aes(x = party, y = neuroticism_score, color = username)) +
  geom_jitter(show.legend = FALSE, size = 2) +
  stat_summary(aes(group = party), geom = "point", size = 8, shape = 3, show.legend = FALSE, colour = "black") +
  stat_summary(aes(group = party), geom = "errorbar", show.legend = FALSE) +
  facet_wrap(~influencer_party, labeller = as_labeller(c(Left = "Left (Influencer)", Right = "Right (Influencer)") )) +
  labs(
    title = "Scatter plot of calculated neuroticism by influencer and follower political alignment",
    x = "Political alignment",
    y = "Calculated neuroticism score") +
  theme(text = element_text(size = 20))

df_tweets %>%
  ggplot(aes(x = party, y = neuroticism_score, color = username)) +
  geom_jitter(show.legend = FALSE) +
  stat_summary(aes(group = party), geom = "point", size = 10, shape = 3, show.legend = FALSE, colour = "black") +
  stat_summary(aes(group = party), geom = "errorbar", show.legend = FALSE)

df_tweets %>%
  ggplot(aes(x = influencer_party, y = neuroticism_score, color = username)) +
  geom_jitter(show.legend = FALSE) +
  stat_summary(aes(group = influencer_party), geom = "point", size = 10, shape = 3, show.legend = FALSE, colour = "black") +
  stat_summary(aes(group = influencer_party), geom = "errorbar", show.legend = FALSE)




library(RColorBrewer)
library(wordcloud2)
library(tidytext)

df_userdata <- read_csv('pol_tweets_leaning.csv')
df_userdata <- df_userdata %>%
  distinct(username, .keep_all = TRUE) %>%
  select(c(username, party, tweet, influencer_party))
head(df_userdata)




df_userdata <- mutate(df_userdata, tweet = str_replace_all(tweet, "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https", ""))

reg_words <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))" #a list of symbols we wanna remove in the proces
df_userdata$tweet <- gsub("@\\S*", "", df_userdata$tweet)
df_userdata <- unnest_tokens(df_userdata, word, tweet, token = "regex", pattern = reg_words)

df_userdata <- df_userdata %>%
  filter(!word %in% stop_words$word)


# df_userdata$tweet <- gsub("https\\S*", "", df_userdata$tweet)
# df_userdata$tweet <- gsub("@\\S*", "", df_userdata$tweet)
# df_userdata$tweet <- gsub("amp", "", df_userdata$tweet)
# df_userdata$tweet <- gsub("[\r\n]", "", df_userdata$tweet)
# df_userdata$tweet <- gsub("[[:punct:]]", "", df_userdata$tweet)











words <- df_userdata %>%
  filter(party == "Left" & influencer_party == "Left") %>%
  count(word, sort = TRUE)
head(words)
wordcloud2(words)

words <- df_userdata %>%
  filter(party == "Right" & influencer_party == "Left") %>%
  count(word, sort = TRUE)
wordcloud2(words)

words <- df_userdata %>%
  filter(party == "Left" & influencer_party == "Right") %>%
  count(word, sort = TRUE)
wordcloud2(words)

words <- df_userdata %>%
  filter(party == "Right" & influencer_party == "Right") %>%
  count(word, sort = TRUE)
wordcloud2(words)
letterCloud(words, word = "RR", wordSize = 1)


