#regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
#This is a comment
#Matches.insert({test: 'test'}) ??yeah
apiKey = Assets.getText 'apikey'
timestamp = 1428040200
everyMinute = new Cron((->
  regions = ['euw']
  for region in regions
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + timestamp + '&api_key=' + apiKey
    HTTP.get url, (err, matchIds) ->
      matchIds = matchIds.data
      for matchId in matchIds
          url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
          HTTP.get url, (err, matchGet) ->
            matchData = matchGet.data
            console.log matchData.matchId
            if Matches.find().count() != 0
              regionUpper = region.toUpperCase()
              if Matches.find(region: regionUpper, matchId: matchData.matchId).count() == 0
                console.log 'INSERTING '+matchData.matchId
                Matches.insert(matchData)
              else
                console.log 'FOUND A DUPLICATE MATCHID: '+matchData.matchId+' - Region: '+regionUpper
), {})