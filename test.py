import tweepy
import os

exit()

auth = tweepy.AppAuthHandler(os.environ.get("TWITTER_API_KEY"), os.environ.get("TWITTER_API_SECRET"))

api = tweepy.API(auth)


def get_followers(thandle):
  return api.followers_ids(screen_name = thandle)

lfile = open('BenShapiro.follwers.txt', 'w')
for page in tweepy.Cursor(api.followers_ids, screen_name = "BenShapiro").pages():
  print("Writing page...")
  for item in page:
    lfile.write('{}\n'.format(item))
lfile.close()

exit()


for follower in api.followers_ids(screen_name = "BenShapiro"):
  lfile.write('{}\n'.format(follower))

lfile.close()
print("Now fuck off...")