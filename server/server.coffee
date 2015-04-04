#regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
apiKey = Assets.getText 'apikey'
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
timestamp = 1428098400
Meteor.setInterval (->
    for region in regions
        getMatchIdsAndInsertMatches(region)
    ), 10000
###everyMinute = new Cron((->
  for region in regions
    getMatchIdsAndInsertMatches(region)
), {})###
getMatchIdsAndInsertMatches = (region) ->
  url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + timestamp + '&api_key=' + apiKey
  regionUpper = region.toUpperCase()
  HTTP.get url, (err, matchIds) ->
    if matchIds.statusCode == 200
        matchIds = matchIds.data
        if matchIds.length != 0
          for matchId in matchIds
            if Matches.find(region: regionUpper, matchId: matchId).count() == 0
              url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
              HTTP.get url, (err, matchGet) ->
                if matchGet.statusCode == 200
                    matchData = matchGet.data
                    matchObj = {
                      matchId: matchData.matchId,
                      region: matchData.region,
                      matchType: matchData.matchType,
                      duration: matchData.duration,
                      teams: matchData.teams,
                      participants: matchData.participants
                    }
                    console.log 'INSERTING '+matchData.matchId+' - TIMESTAMP: '+timestamp
                    Matches.insert(matchObj)
                else
                    'GET MATCH - ERROR - STATUSCODE: '+matchIds.statusCode
            else
              console.log 'FOUND A DUPLICATED MATCHID: '+matchId+' - Region: '+regionUpper
    else
        console.log 'GET MATCHIDS - ERROR - STATUSCODE: '+matchIds.statusCode
  timestamp = timestamp-300



# bans = []
# for match in Matches.find({region: 'BR'}).fetch()
#   for team in match.teams
#     if team.bans 
#       for ban in team.bans
#         bans.push ban.championId
# console.log bans.length 
# Bans.insert({
#   region: 'BR',
#   bans: bans
#   })