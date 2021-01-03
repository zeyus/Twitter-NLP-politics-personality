import csv
files = [
  'pre_sentiment_democrat',
  'pre_sentiment_republican',
  'pre_sentiment_JoeBiden',
  'pre_sentiment_realDonaldTrump',
]
for file in files:
  out = []
  with open("{}.csv".format(file), encoding = 'cp850') as csv_file:
    readc = csv.reader(csv_file)
    for row in readc:
      out.append(row)
  with open("data/{}_fixed.csv".format(file), 'w', newline='', encoding='utf-8') as out_file:
    writec = csv.writer(out_file, quoting=csv.QUOTE_ALL)
    writec.writerows(out)
