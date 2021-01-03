$twhandles = Get-Content remaining_influencers.txt

foreach ($twhandle in $twhandles)
{
  twint -u "$twhandle" -o tweets_$twhandle.json --json
}