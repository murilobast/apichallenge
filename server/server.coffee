apiKey = Assets.getText 'apikey'
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
timestamp = 1428251700
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
                console.log matchIds
                if matchIds.length != 0
                    for matchId in matchIds
                        getMatches(region, regionUpper, matchId)
            else
                console.log "GET MATCHID'S - ERROR - STATUSCODE: "+matchIds.statusCode
        else
            console.log err

tryEveryRegion = ->
    for region in regions
        getMatchIds(region)
#tryEveryRegion()

getMatches = (region, regionUpper, matchId) ->
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
    HTTP.get url, (err, result) ->
        if result.statusCode == 200
            console.log 'GOT MATCH FROM MATCHID: '+matchId+' - REGION: '+regionUpper
            matchData = result.data
            checkForChampions(region, regionUpper, matchData)
            getTeamsBanData(region, regionUpper, matchData)
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
        championData['doubleKills'] = participant.stats.doubleKills
        championData['tripleKills'] = participant.stats.tripleKills
        championData['quadraKills'] = participant.stats.quadraKills
        championData['pentaKills'] = participant.stats.pentaKills
        championData['unrealKills'] = participant.stats.unrealKills
        championData['assists'] = participant.stats.assists
        championData['deaths'] = participant.stats.deaths
        championData['wins'] = 0
        championData['losses'] = 0
        championData['winrate'] = 0
        championData['likes'] = []
        if participant.stats.winner == true
            championData['wins'] = 1
            championData['winrate'] = 1
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
        championWins = championWin+Champions.find({id: championId, region: regionUpper}).fetch()[0].wins
        championLosses = Champions.find({id: championId, region: regionUpper}).fetch()[0].losses
        championGames = championWins+championLosses
        championWinRate = championWins/championGames
    else
        championLoss = 1
        championLosses = championLoss+Champions.find({id: championId, region: regionUpper}).fetch()[0].losses
        championWins = Champions.find({id: championId, region: regionUpper}).fetch()[0].wins
        championGames = championWins+championLosses
        championWinRate = championWins/championGames
    Champions.update(id: championId, region: regionUpper, {
        $inc: {
            kills: participant.stats.kills
            doubleKills: participant.stats.doubleKills
            tripleKills: participant.stats.tripleKills
            quadraKills: participant.stats.quadraKills
            pentaKills: participant.stats.pentaKills
            unrealKills: participant.stats.unrealKills
            assists: participant.stats.assists
            deaths: participant.stats.deaths
            wins: championWin
            losses: championLoss
        }
        $set: {
            winrate: championWinRate
        }
    })

getTeamsBanData = (region, regionUpper, matchData) ->
    for teamsBanData in matchData.teams[0].bans
        addBansToEachChampion(region, regionUpper, teamsBanData)
    for teamsBanData in matchData.teams[1].bans
        addBansToEachChampion(region, regionUpper, teamsBanData)

addBansToEachChampion = (region, regionUpper, teamsBanData) ->
    championIdBan = teamsBanData.championId
    console.log championIdBan
    if Champions.find({region: regionUpper, id: championIdBan}).count() == 0
        url = 'https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion/'+championIdBan+'?api_key='+apiKey
        result = HTTP.get url
        if result.statusCode == 200
            championData = result.data
            championData['region'] = regionUpper
            championData['bans'] = 1
            Champions.insert(championData)
        else
            console.log 'GET CHAMPION - ERROR - STATUSCODE: '+result.statusCode
    else if Champions.findOne({id: championIdBan, region: regionUpper, bans: {$exists: false}})
        Champions.update(id: championIdBan, region: regionUpper, {
            $set: {bans: 1}
        })
    else
        Champions.update(id: championIdBan, region: regionUpper, {
            $inc: {bans: 1}
        })