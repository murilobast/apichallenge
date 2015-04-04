apiKey = Assets.getText 'apikey'
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
timestamp = 1428098400

###For testing
Meteor.setInterval (->
        for region in regions
                getMatchIdsAndInsertMatches(region)
        ), 10000
###

#For production
everyMinute = new Cron((->
    for region in regions
        getMatchIdsAndInsertMatches(region)
), {})

# This is for updating the champions collection
makeIChampionObj = (region) ->
    regionUpper = region.toUpperCase()
    url = 'https://'+region+'.api.pvp.net/api/lol/'+region+'/v1.2/champion?api_key='+apiKey
    HTTP.get url, (err, championsGet) -> 
        if championsGet.statusCode == 200
            champions = championsGet.data.champions
            for champion in champions
                championId = champion.id 
                console.log championId
                if Champions.find({id: championId, region: regionUpper}).count() == 0
                    console.log "doesn't exist"
                    url = 'https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion/'+championId+'?api_key='+apiKey
                    championGet = HTTP.get url
                    if championGet.statusCode == 200
                        championData = championGet.data
                        champion = {
                            region: regionUpper
                            id: championId
                            name: championData.name
                            key: championData.key
                            title: championData.title
                            likes: []
                        }
                        Champions.insert(champion)
                    else
                        console.log championGet.statusCode
                else
                    console.log 'exist'
        else
            console.log championsGet.statusCode

# for region in regions
#     makeIChampionObj(region)

updateChampionObj = (match) ->
    regionUpper = match.region
    championLatestTimestamp = match.timestamp
    for participant in match.participants
        championId = participant.championId
        championKills = participant.stats.kills
        championAssists = participant.stats.assists
        championDeaths = participant.stats.deaths
        championWin = 0
        championLoss = 0
        if Champions.find({id: championId, region: regionUpper}).count() > 0
            if participant.stats.winner == true
                championWin = 1
            else
                championLoss = 1
            champion = {
                kills: championKills
                assists: championAssists
                deaths: championDeaths
                wins: championWin
                losses: championLoss
                latestTimestamp: championLatestTimestamp
            }
            console.log 'INSERTING CHAMPION!'
            if Champions.findOne({id: championId, region: regionUpper, kills: {$exists: false}})
                Champions.update({id: championId, region: regionUpper}, {$set: champion})
            else
                Champions.update({id: championId, region: regionUpper}, {
                    $inc: {
                        kills: championKills
                        assists: championAssists
                        deaths: championDeaths
                        wins: championWin
                        losses: championLoss
                    }
                    $set: {latestTimestamp: championLatestTimestamp}
                    })
        else
            #update stuff missing a lot
            #reusingChampData = Champions.find({championId: championId, region: championRegion}).fetch[0]
            console.log 'ALREADY IN DATABASE!'

# makeInsertAndUpdateChampionObj('br')

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
                                    matchId: matchData.matchId
                                    region: matchData.region
                                    matchType: matchData.matchType
                                    duration: matchData.duration
                                    teams: matchData.teams
                                    participants: matchData.participants
                                    timestamp: timestamp
                                }
                                updateChampionObj(matchObj)
                            else
                                console.log 'GET MATCH - ERROR - STATUSCODE: '+matchIds.statusCode
                    else
                        console.log 'FOUND A DUPLICATED MATCHID: '+matchId+' - Region: '+regionUpper
        else
            console.log 'GET MATCHIDS - ERROR - STATUSCODE: '+matchIds.statusCode
    timestamp = timestamp-300

# updateMatchObj = ->
#     for match in Matches.find({region: 'EUW'}).fetch()
#         updateChampionObj(match)
# updateMatchObj()

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