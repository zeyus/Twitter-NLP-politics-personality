from json.encoder import JSONEncoder
import json
data = []

with open('tweets_to_neiltyson.json') as file_object:
  for line in file_object:
      data.append(json.loads(line))

print("num json data objects: {}".format(len(data)))
ids = {}
for entry in data:
  prev = 0
  if entry['user_id'] in ids:
    # print('repeated: {}'.format(entry['user_id']))
    prev = ids[entry['user_id']]
  ids[entry['user_id']] = prev + 1

print("num ids: {}".format(len(ids)))
occur_count = {}
mega_users = []
for (uid, occurs) in ids.items():
  if occurs > 1:
    if occurs not in occur_count:
      occur_count[occurs] = 0
    occur_count[occurs] = occur_count[occurs] + 1
  if occurs > 27:
    mega_users.append({'user_id': uid, 'tweets_at_influencer': occurs})
    # print("uid: {}, # occurrences: {}".format(uid, occurs))

print("Number of tweets to ethan | # users with this count")
occur_count = sorted(occur_count.items(), key = lambda kv: kv[0])
occur_count = dict(occur_count)
for (occurs, num) in occur_count.items():
  print("{} | {}".format(occurs, num))

outfile = open('active_tweeters_to_neiltyson.json', 'w')
json.dump(mega_users, outfile)
outfile.close()