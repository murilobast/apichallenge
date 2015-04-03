#regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
#This is a comment
#Matches.insert({test: 'test'}) ??yeah
Matches.insert {test: 'test'}
apiKey = Assets.getText 'apikey'
timestamp = 1428040200
everyMinute = new Cron((->
  regions = ['euw']
  for region in regions
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + timestamp + '&api_key=' + apiKey
    matchIds = HTTP.get url
    matchIds = matchIds.data
    for matchId in matchIds
        url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
        matchGet = HTTP.get url
        matchData = matchGet.data
        Matches.insert(matchData)
), {})