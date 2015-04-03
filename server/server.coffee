#regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
#This is a comment
#Matches.insert({test: 'test'}) ??yeah
key = Assets.getText 'apikey'
everyMinute = new Cron((->
  regions = ['euw']
  time = 1428040200 #9min ago
  for region in regions
    url = 'https:/' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + time + '&api_key=' + key
    matchIds = HTTP.get url
    matchIds = matchIds.data
    for matchId in matchIds
        url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?api_key=' + key
        game = HTTP.get url
        console.log game.data.matchId
    # url = 'https://'+region+'.api.pvp.net/api/lol/na/v2.2/match/' + matchId goes here + '?api_key=' + key
    # correct!
), {})