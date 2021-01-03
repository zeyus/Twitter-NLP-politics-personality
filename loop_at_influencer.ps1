$twhandles = Get-Content remaining_influencers.txt

foreach ($twhandle in $twhandles)
{
  twint -s "@$twhandle -filter:links -filter:replies" -o tweets_to_$twhandle.json --json
}