from json.encoder import JSONEncoder
import json, os

# with open('data/tweets_to_x/tweets_to_elon_fixed.json') as file_object:
#   for line in file_object:
#       data.append(json.loads(line))

files = os.listdir("data/tweets_to_x/")
for f in files:
  if not ".json" in f:
    continue
  if not "_fixed.json" in f:
    continue
  print("processing file: {}".format(f))
  out_user = f.split("_")[-2]
  with open("data/tweets_to_x/" + f, encoding = 'cp850') as file_object:
    data = json.load(file_object)
  print("num json data objects: {}".format(len(data)))
  ids = {}
  for entry in data:
    prev = []
    if entry['username'] in ids:
      # print('repeated: {}'.format(entry['user_id']))
      prev = ids[entry['username']]
    prev.append(entry)
    ids[entry['username']] = prev

  print("num unique users: {}".format(len(ids)))
  occur_count = {}
  mega_users = []
  for (uid, tweets) in ids.items():
    occurs = len(tweets)
    if occurs > 1:
      if occurs not in occur_count:
        occur_count[occurs] = 0
      occur_count[occurs] = occur_count[occurs] + 1
    if occurs > 9:
      mega_users.append({'username': uid, 'tweets_at_influencer': occurs})
      outfile = open('data/to_x_y_tweets_from_z/to_{}_{}_tweets_from_{}.json'.format(out_user, occurs, uid), 'w')
      json.dump(tweets, outfile)
      outfile.close()
      # {'username': uid, 'tweets_at_influencer': occurs, 'content': tweets}
      # print("uid: {}, # occurrences: {}".format(uid, occurs))

  print("Number of tweets to {} | # users with this count".format(out_user))
  occur_count = sorted(occur_count.items(), key = lambda kv: kv[0])
  occur_count = dict(occur_count)
  for (occurs, num) in occur_count.items():
    print("{} | {}".format(occurs, num))

  outfile = open('data/active_tweeters_to_x/active_tweeters_to_{}.json'.format(out_user), 'w')
  mega_users = sorted(mega_users, key=lambda k: k['tweets_at_influencer'], reverse=True)
  item_count = min(65, len(mega_users))
  mega_users = mega_users[:item_count]
  json.dump(mega_users, outfile)
  outfile.close()