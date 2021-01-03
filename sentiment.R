library(tidyverse)
library(tidytext)
library(stringr)

df1 <- read_csv("data/pre_sentiment_republican_fixed.csv", skip_empty_rows = FALSE)
df2 <- read_csv("data/pre_sentiment_realDonaldTrump_fixed.csv", skip_empty_rows = FALSE)
tweets_r <- rbind(df1, df2)
rm(df1, df2)
tweets_r$pol <- "r"
nrow(tweets_r)
tweets_r <- filter(tweets_r, !grepl("democrat|joebiden", tweet, ignore.case = TRUE))
nrow(tweets_r)


df1 <- read_csv("data/pre_sentiment_democrat_fixed.csv", skip_empty_rows = FALSE)
df2 <- read_csv("data/pre_sentiment_JoeBiden_fixed.csv", skip_empty_rows = FALSE)
tweets_l <- rbind(df1, df2)
rm(df1, df2)
tweets_l$pol <- "l"
nrow(tweets_l)
tweets_l <- filter(tweets_l, !grepl("republican|realdonaldtrump",tweet,ignore.case = TRUE))
nrow(tweets_l)
tweets <- rbind(tweets_l, tweets_r)
rm(tweets_l, tweets_r)
tweets <- tweets[c("id", "date", "username", "tweet", "language", "pol")]
head(tweets)
nrow(tweets)

tweets <- distinct(tweets, id, .keep_all = TRUE)
test <- tweets[!(tweets$username %in% remove),]
nrow(test)
head(tweets$username)
length(distinct(tweets, username)$username)
temp <- distinct(tweets, username)
temp <- temp[!(temp$username %in% remove),]
length(temp$username)


tweets <- mutate(tweets, tweet = str_replace_all(tweet, "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https", ""))

reg_words <- "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))" #a list of symbols we wanna remove in the proces

tweets <- unnest_tokens(tweets, word, tweet, token = "regex", pattern = reg_words)

tweets <- tweets %>%
  filter(!word %in% stop_words$word)

sentiment <- get_sentiments("bing")

sentiment_tweets <- tweets %>%
  inner_join(sentiment)

sentiment_score_tweets <- sentiment_tweets %>%
  group_by(username, pol, sentiment)  %>%
  summarise(count = n()) %>%
  mutate(freq = count / sum(count))
sentiment_score_tweets
sentiment_score_tweets$freq[sentiment_score_tweets$sentiment == "negative"] = -sentiment_score_tweets$freq[sentiment_score_tweets$sentiment == "negative"]
# write_csv(sentiment_score_tweets, "test.csv")
sum_scores <- sentiment_score_tweets %>% group_by(username, pol) %>%
  summarise(freq = sum(freq), count_pol = sum(count), .groups = "keep")
sum_scores$freq[sum_scores$pol == "l"] <- -sum_scores$freq[sum_scores$pol == "l"]
head(sum_scores)
leaning <- sum_scores %>%
  group_by(username) %>%
  summarise(pol_leaning = sum(freq), samples = sum(count_pol))

leaning$abs_pol_leaning <- abs(leaning$pol_leaning)
leaning$party <- NA
leaning$party[leaning$pol_leaning < 0] <- "Left"
leaning$party[leaning$pol_leaning > 0] <- "Right"

nrow(leaning)
remove <- c(
  "msblairewhite",
  "rubinreport",
  "benshapiro",
  "ingrahamangle",
  "contrapoints",
  "vaushv",
  "hbomberguy",
  "thelindsayellis",
  "glennbeck",
  "kellyannepolls",
  "shoe0nhead",
  "philosophytube",
  # plus some parody / news accounts
  "leavetheovaloff",
  "vinsulting"
)

leaning <- leaning[!(leaning$username %in% remove),]
leaning <- leaning[!(leaning$abs_pol_leaning < 0.1),]
leaning <- leaning[!(leaning$samples < 30),]
nrow(leaning)
leaning <- leaning[order(leaning$abs_pol_leaning, decreasing = TRUE),]
head(leaning)


# remove influencers


write_csv(leaning, "political_leaning_above_point_1_abs.csv")
