import json
import os

def append_suffix(filename, suffix):
    name, ext = os.path.splitext(filename)
    return "{name}_{suffix}{ext}".format(name=name, suffix=suffix, ext=ext)

tweet_dirs = ['data/tweets_to_x/', 'data/tweet_w_big5/']
columns = ["conversation_id", "created_at", "date", "time", "timezone", "username", "name", "place", "tweet", "language"]

for tweet_dir in tweet_dirs:
  files = os.listdir(tweet_dir)
  for f in files:
    if not ".json" in f:
      continue
    if "_fixed.json" in f:
      continue
    print("Processing file: {}".format(f))
    fname_out = append_suffix(tweet_dir + f, 'fixed')
    if os.path.exists(fname_out):
      print("Not overwriting existing file: '{}', skipping to next".format(fname_out))
      continue
    duplicates = 0
    data = []
    tweet_ids = {}

    with open(tweet_dir + f) as file_object:
      for line in file_object:
        row = json.loads(line)
        if row['id'] in tweet_ids:
          duplicates = duplicates + 1
          continue
        tweet_ids[row['id']] = True
        row_save = {}
        for col in columns:
          row_save[col] = row[col]
        data.append(row_save)
    
    outfile = open(fname_out, 'w')
    json.dump(data, outfile)
    outfile.close()
    print("Finished processing. Saved to: '{}'. {} duplicates found.".format(fname_out, duplicates))