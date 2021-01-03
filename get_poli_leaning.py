import twint, os, json
import time

dir = 'data/active_tweeters_to_x/'
#files = os.listdir(dir)
files = [
  'active_tweeters_to_glennbeck.json',
  'active_tweeters_to_KellyannePolls.json',
  'active_tweeters_to_PhilosophyTube.json',
  'active_tweeters_to_shoe0nhead.json',
]
searches = [
  'realDonaldTrump',
  'republican',
  'JoeBiden',
  'democrat'
]



###############################################
# followers = ["philbuni", "johnpa598", "gayestfesh"]
# for follower in followers:
#   for search in searches:
#     print("Processing user: '{}', search: '{}'".format(follower, search))
#     tweets = []
#     c = twint.Config()
#     c.Username = follower
#     c.Search = search
#     c.Store_csv = True
#     c.Output = "pre_sentiment_{}.csv".format(search)
#     c.Since = "2020-01-01"
#     # c.Store_object_tweets_list = tweets
#     twint.run.Search(c)
#     time.sleep(1)

# quit()
#####################################################




all_data = []
for f in files:
  if not ".json" in f:
    continue
  with open(dir + f, encoding = 'cp850') as file_object:
    followers = json.load(file_object)
  for follower in followers:
    for search in searches:
      print("Processing user: '{}', search: '{}'".format(follower['username'], search))
      tweets = []
      c = twint.Config()
      c.Username = follower['username']
      c.Search = search
      c.Store_csv = True
      c.Output = "pre_sentiment_{}.csv".format(search)
      c.Since = "2020-01-01"
      # c.Store_object_tweets_list = tweets
      twint.run.Search(c)
      time.sleep(1)
      # for tweet in tweets:
      #   all_data.append([follower['username'], search, tweet.datestamp, tweet.tweet, tweet.retweet])
# outfile = open('pre_sentiment_data.json', 'w')
# json.dump(all_data, outfile)
# outfile.close()

