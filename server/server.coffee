#regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
apiKey = Assets.getText 'apikey'
timestamp = 1428098400
everyMinute = new Cron((->
  regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
  for region in regions
    getMatchIdsAndInsertMatches(region)
), {})
getMatchIdsAndInsertMatches = (region) ->
  url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + timestamp + '&api_key=' + apiKey
  regionUpper = region.toUpperCase()
  HTTP.get url, (err, matchIds) ->
    matchIds = matchIds.data
    if matchIds.length != 0
      for matchId in matchIds
        if Matches.find(region: regionUpper, matchId: matchId).count() == 0
          url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
          HTTP.get url, (err, matchGet) ->
            matchData = matchGet.data
            console.log 'INSERTING '+matchData.matchId
            Matches.insert(matchData)
        else
          console.log 'FOUND A DUPLICATE MATCHID: '+matchId+' - Region: '+regionUpper