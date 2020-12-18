library("easystats")
library(tidyverse)
library(quanteda)
library(readtext)
library(reshape2)
# library(ggradar)
library(ggpubr)


score_types <- c(
  "z_freq",
  "zr_freq"
  # "norm_freq",
  # "rel_freq"
)


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

create_LIWC_data_frame <- function(filename, liwc_dict, group_name = "follower", group_by = "username") {
  #### JSON FROM TWINT
  # group by tweet language
  corpus_tweets <- corpus(
    readtext(filename,
    text_field = "tweet"))

  if (group_by == "language") {
    corpus_tweets <- corpus_subset(corpus_tweets, language == "en")
  }
  # Create a document-feature matrix to map the LIWC dictionary
  dfm_tweets <- dfm(
    corpus_tweets,
    groups = group_by,
    dictionary = liwc_dict,
    verbose = TRUE)

  df_tweets <- convert(t(dfm_tweets), to = "data.frame")
  names(df_tweets) <- c("LIWC_Cat", "Freq")


  df_tweets$z_freq <- effectsize::standardize(df_tweets$Freq)
  df_tweets$zr_freq <- effectsize::standardize(df_tweets$Freq, robust = TRUE)
  df_tweets$norm_freq <- effectsize::normalize(df_tweets$Freq)

  df_tweets$rel_freq <- with(df_tweets, Freq / sum(Freq))
  df_tweets$group <- group_name
  df_tweets
}




df_tweets_1 <- create_LIWC_data_frame("data/tweets_to_x/tweets_to_neiltyson_fixed.json", liwc_dict, "neil degrasse tyson", "language")
df_tweets_2 <- create_LIWC_data_frame("data/tweets_to_x/tweets_to_BenShapiro_fixed.json", liwc_dict, "ben shapiro", "language")
df_tweets_3 <- create_LIWC_data_frame("data/tweets_to_x/tweets_to_SamHarrisOrg_fixed.json", liwc_dict, "sam harris", "language")
df_tweets_4 <- create_LIWC_data_frame("data/tweets_to_x/tweets_to_rustyrockets_fixed.json", liwc_dict, "russel brand", "language")
df_tweets_comb <- rbind(df_tweets_1, df_tweets_2, df_tweets_3, df_tweets_4)
ggdotchart(df_tweets_comb,
  x = "LIWC_Cat",
  y = "norm_freq",
  color = "group",
  group = "group",
  sorting = "none",
  add = "segment",
  position = position_dodge(0.8)
)

# df_tweets <- as.data.frame(t(df_tweets))
# names(df_tweets) <- df_tweets[1,]
# df_tweets <- df_tweets[-2,]
# df_tweets <- rownames_to_column(df_tweets, "group")

# df_tweets[0:-1] <- sapply(df_tweets[0:-1], as.numeric)

# scale_min <- min(df_tweets[0:-1])
# scale_max <- max(df_tweets[0:-1])
# scale_mid <- (scale_max - scale_min) / 2
# df_tweets
# str(df_tweets)
# sapply(df_tweets, class)
# ggradar(df_tweets,
#   grid.min = scale_min,
#   grid.max = scale_max,
#   grid.mid = scale_mid
# )



# summary_scores.molten %>% ggplot(aes(x = dimension, y = Freq, fill = Method)) +
#   geom_bar(position = "dodge", stat = "identity") +
#   theme(text = element_text(size = 20)) +
#   geom_text(aes(label = round(Freq, 3)), vjust = -0.2, position = "dodge")
