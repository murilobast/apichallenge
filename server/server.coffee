apiKey = Assets.getText 'apikey'
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
timestamp = 1428185400
testCount = 1

#For testing
#Meteor.setInterval (->
#    for region in regions
#        getMatchIds(region)
#        #getMatchIdsAndInsertMatches(region)
#    timestamp = timestamp-300
#    ), 10000

#For production
#everyMinute = new Cron((->
#    for region in regions
#       getMatchIds(region)
#        #getMatchIdsAndInsertMatches(region)
#    timestamp = timestamp-300
#), {})

checkCollection = ->
    for champ in Champions.find({region: "EUNE"}).fetch()
        test = champ.wins+champ.losses
        console.log 'NAME: '+champ.name+' - ID: '+champ.id+' - KILLS: '+champ.kills+' - ROUNDS: '+test
#checkCollection()

getMatchIds = (region) ->
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + timestamp + '&api_key=' + apiKey
    regionUpper = region.toUpperCase()
    HTTP.get url, (err, result) ->
        if not err
            if result.statusCode == 200
                console.log "GOT MATCHID'S FOR: "+regionUpper+' - TIMESTAMP: '+timestamp
                matchIds = result.data
                if matchIds.length != 0
                    getMatches(region, regionUpper, matchIds)
            else
                console.log "GET MATCHID'S - ERROR - STATUSCODE: "+matchIds.statusCode
        else
            console.log err

tryEveryRegion = ->
    for region in regions
        getMatchIds(region)
#tryEveryRegion()

getMatches = (region, regionUpper, matchIds) ->
    for matchId in matchIds
        url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
        HTTP.get url, (err, result) ->
            if result.statusCode == 200
                console.log 'GOT MATCH FROM MATCHID: '+matchId+' - REGION: '+regionUpper
                matchData = result.data
                checkForChampions(region, regionUpper, matchData)
            else
                console.log 'GET MATCH - ERROR - STATUSCODE: '+result.statusCode

checkForChampions = (region, regionUpper, matchData) ->
    for participant in matchData.participants
        championId = participant.championId
        if Champions.find({region: regionUpper, id: championId}).count() == 0
            insertNewChampionObj(region, regionUpper, matchData, participant, championId)
        else
            updateChampionObj(region, regionUpper, matchData, participant, championId)

insertNewChampionObj = (region, regionUpper, matchData, participant, championId) ->
    url = 'https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion/'+championId+'?api_key='+apiKey
    result = HTTP.get url
    if result.statusCode == 200
        championData = result.data
        championData['region'] = regionUpper
        championData['kills'] = participant.stats.kills
        championData['assists'] = participant.stats.assists
        championData['deaths'] = participant.stats.deaths
        championData['wins'] = 0
        championData['losses'] = 0
        championData['likes'] = []
        if participant.stats.winner == true
            championData['wins'] = 1
        else
            championData['losses'] = 1
        if Champions.find({region: regionUpper, id: championId}).count() == 0
            console.log 'INSERTING NEW CHAMPION ID: '+championId+' - REGION: '+regionUpper
            Champions.insert(championData)
        else
            updateChampionObj(region, regionUpper, matchData, participant, championId)
    else
        console.log 'GET CHAMPION - ERROR - STATUSCODE: '+result.statusCode

updateChampionObj = (region, regionUpper, matchData, participant, championId) ->
    #console.log 'UPDATING CHAMPION ID: '+championId+' - REGION: '+regionUpper
    championWin = 0
    championLoss = 0
    if participant.stats.winner == true
        championWin = 1
    else
        championLoss = 1
    Champions.update({id: championId, region: regionUpper}, {
        $inc: {
            kills: participant.stats.kills
            assists: participant.stats.assists
            deaths: participant.stats.deaths
            wins: championWin
            losses: championLoss
            }
        })
















#MAYBE DELETE ALL THIS?
#Making a game field in my collection and updating the winrate
updateAllChampions = (region) ->
    regionUpper = region.toUpperCase()
    for champion in Champions.find(region: regionUpper).fetch()
        id = champion.id
        wins = champion.wins
        losses = champion.losses
        games = wins + losses
        winrate = wins/games
        update = {
            games: games
            winrate: winrate
        }
        console.log 'UPDATING CHAMPION '+id+' - SERVER '+regionUpper
        Champions.update({id: id, region: regionUpper}, {$set: update})
# for region in regions
#     updateAllChampions(region)

# This is for updating the champions collection
makeIChampionObj = (region) ->
    regionUpper = region.toUpperCase()
    url = 'https://'+region+'.api.pvp.net/api/lol/'+region+'/v1.2/champion?api_key='+apiKey
    HTTP.get url, (err, championsGet) -> 
        if championsGet.statusCode == 200
            champions = championsGet.data.champions
            for champion in champions
                championId = champion.id 
                if Champions.find({id: championId, region: regionUpper}).count() == 0
                    console.log "INSERTING CHAMPION "+championId+" SERVER "+regionUpper
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
                    console.log "CHAMPION "+championId+" SERVER "+regionUpper+' EXISTS'
        else
            console.log championsGet.statusCode

# for region in regions
#     makeIChampionObj(region)
###
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
                games: 1
                latestTimestamp: championLatestTimestamp
            }
            if Champions.findOne({id: championId, region: regionUpper, kills: {$exists: false}})
                console.log 'NEW CHAMPION FIELDS BEING INSERTED! ID: '+championId+' SERVER: '+regionUpper
                Champions.update({id: championId, region: regionUpper}, {$set: champion})
            else
                console.log 'UPDATING CHAMPION DATA!ID: '+championId+' SERVER: '+regionUpper
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
###
#makeInsertAndUpdateChampionObj('euw')
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
#
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