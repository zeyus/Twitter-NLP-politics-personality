library(tidyverse)

dfn <- read_csv("data/processed_neuroticism_top_tweeters_to_influencers.csv")
head(dfn)
dfn$influencer <- str_split(dfn$user, "_", simplify = TRUE)[,2]


filter(dfn, dim == "neuroticism") %>% ggplot(aes(x = influencer, y = freq, color = influencer, group = influencer)) +
  geom_jitter() +
  stat_summary(fun.y=mean,geom="line",lwd=1,aes(group=1), color = "black") +
  stat_summary(
    geom = "point",
    fun.y = "mean",
    col = "black",
    size = 3,
    shape = 24,
    fill = "red"
  )

dfn <- read_csv("data/processed_neuroticism_all_tweets_influencers.csv")
head(dfn)

filter(dfn, dim == "neuroticism") %>% ggplot(aes(x = user, y = freq, color = user)) +
  stat_summary(fun.y=mean,geom="line",lwd=0.5,aes(group=1), color = "black") +
  geom_point(size = 3)
  geom_line()
