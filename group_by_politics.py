import json, os, csv, re, fnmatch


influencers = {
  'MsBlaireWhite':	'Right',
  'RubinReport':	'Right',
  'BenShapiro':	'Right',
  'IngrahamAngle':	'Right',
  'ContraPoints':	'Left',
  'VaushV':	'Left',
  'hbomberguy':	'Left',
  'TheLindsayEllis':	'Left',
  'glennbeck':	'Right',
  'KellyannePolls':	'Right',
  'shoe0nhead':	'Left',
  'PhilosophyTube':	'Left'
}

out = {
  'Left': {},
  'Right': {}
}
with open("political_leaning_above_point_1_abs.csv", encoding = 'utf-8') as csv_file:
  readc = csv.reader(csv_file)
  header_skipped = False
  for row in readc:
    if not header_skipped:
      header_skipped = True
      continue
    out[row[4]][row[0]] = {
      'username': row[0],
      'pol_leaning': float(row[1]),
      'samples': int(row[2]),
      'abs_pol_leaning': float(row[3]),
      'party': row[4],
    }

# now we get their scraped tweets:
full_data_set = []
dir = './data/to_x_y_tweets_from_z/'
for party in out.values():
  for user in party.values():
    rule = re.compile(fnmatch.translate('*_{}.json'.format(user['username'])), re.IGNORECASE)
    users_tweet_files = [name for name in os.listdir(dir) if rule.match(name)]
    for file in users_tweet_files:
      with open(dir + file, encoding = 'cp850') as file_object:
        file_parts = file.split('_')
        influencer = file_parts[1]
        user['influencer'] = influencer
        user['influencer_party'] = influencers[influencer]
        tweets = json.load(file_object)
        for tweet in tweets:
          row = user.copy()
          row['conversation_id'] = tweet['conversation_id']
          row['tweet'] = tweet['tweet']
          row['language'] = tweet['language']
          full_data_set.append(row.copy())

with open("pol_tweets_leaning.csv", mode = 'w', encoding='utf-8') as csvfile:
  csv_writer = csv.DictWriter(csvfile, row.keys())
  csv_writer.writeheader()
  csv_writer.writerows(full_data_set)