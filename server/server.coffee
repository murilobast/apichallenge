apiKey = Assets.getText 'apikey'
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
timestamp = 1428393900
testCount = 1

#For testing
#Meteor.setInterval (->
#    for region in regions
#        getMatchIds(region)
#    timestamp = timestamp-300
#    ), 5000

getTime = ->
    date = new Date
    dateFlat = new Date
    dateFlat.setMinutes(Math.round(dateFlat.getMinutes()/5) * 5) % 60
    dateFlat.setSeconds(0)
    if dateFlat.getMinutes() > date.getMinutes()
        dateFlat.setMinutes(dateFlat.getMinutes() - 5)
    date = Number(dateFlat).toString().slice(0,-3)
    date

#For production
#everyHour = new Cron((->
#    timestamp = getTime()
#    Meteor.setInterval (->
#        for region in regions
#            getMatchIds(region)
#            timestamp = timestamp-300
#        ), 300000
#), {
#    minute: 4
#})

checkCollection = ->
    #for champ in Champions.find({region: "EUNE"}).fetch()
    #    test = champ.wins+champ.losses
    #    console.log 'NAME: '+champ.name+' - ID: '+champ.id+' - KILLS: '+champ.kills+' - ROUNDS: '+test
    console.log 'test'
#checkCollection()

getMatchIds = (region) ->
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + timestamp + '&api_key=' + apiKey
    regionUpper = region.toUpperCase()
    HTTP.get url, (err, result) ->
        if not err
            if result.statusCode == 200
                console.log "GOT MATCHID'S FOR: "+regionUpper+' - TIMESTAMP: '+timestamp
                matchIds = result.data
                if matchIds.length > 0
                    for matchId in matchIds
                        getMatches(region, regionUpper, matchId)
            else
                console.log "GET MATCHID'S - ERROR - STATUSCODE: "+matchIds.statusCode
        else
            console.log err
            timestamp = timestamp-300

tryEveryRegion = ->
    for region in regions
        getMatchIds(region)
#tryEveryRegion()

getMatches = (region, regionUpper, matchId) ->
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
    HTTP.get url, (err, result) ->
        if not err
            if result.statusCode == 200
                console.log 'GOT MATCH FROM MATCHID: '+matchId+' - REGION: '+regionUpper
                matchData = result.data
                checkForChampions(region, regionUpper, matchData)
                getTeamsBanData(region, regionUpper, matchData)
                #insertMatches(regionUpper, matchData)
            else
                console.log 'GET MATCH - ERROR - STATUSCODE: '+result.statusCode
        else
            console.log err

insertMatches = (regionUpper, matchData) ->
    console.log testCount+' - INSERTING MATCHDATA - REGION: '+regionUpper+' - TIMESTAMP: '+timestamp
    testCount++
    matchData['timestamp'] = timestamp+300
    Matches.insert(matchData)
    #if Matches.find({region: regionUpper, matchId: matchData.matchId, timestamp: timestamp+300}).count() == 0
    #    console.log 'INSERTING MATCHDATA - REGION: '+regionUpper+' - TIMESTAMP: '+timestamp
    #    Matches.insert(matchData)
    #else
    #    console.log 'MATCH ALREADY EXIST'

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
        championData['games'] = 1
        championData['winrate'] = 0
        championData['likes'] = []
        championData['bans'] = 0
        if participant.stats.winner == true
            championData['wins'] = 1
            championData['winrate'] = 1
        else
            championData['losses'] = 1
        if Champions.find({region: regionUpper, id: championId}).count() == 0
            #console.log 'INSERTING NEW CHAMPION ID: '+championId+' - REGION: '+regionUpper
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
            games: 1
        }
        $set: {
            winrate: championWinRate
        }
    })

getTeamsBanData = (region, regionUpper, matchData) ->
    teamsBanDataResult = []
    if matchData.teams[0].bans != undefined
        for teamsBanData in matchData.teams[0].bans
            teamsBanDataResult.push(teamsBanData)
    if matchData.teams[1].bans != undefined
        for teamsBanData in matchData.teams[1].bans
            teamsBanDataResult.push(teamsBanData)
    if teamsBanDataResult.length > 0
        for teamsBanData in teamsBanDataResult
            addBansToEachChampion(region, regionUpper, teamsBanData)

addBansToEachChampion = (region, regionUpper, teamsBanData) ->
    championIdBan = teamsBanData.championId
    if Champions.find({region: regionUpper, id: championIdBan}).count() == 0
        url = 'https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion/'+championIdBan+'?api_key='+apiKey
        result = HTTP.get url
        if result.statusCode == 200
            championData = result.data
            championData['region'] = regionUpper
            championData['bans'] = 1
            if Champions.find({region: regionUpper, id: championIdBan}).count() == 0
                Champions.insert(championData)
            else
                Champions.update(id: championIdBan, region: regionUpper, {
                    $inc: {bans: 1}
                })
        else
            console.log 'GET CHAMPION - ERROR - STATUSCODE: '+result.statusCode
    else
        Champions.update(id: championIdBan, region: regionUpper, {
            $inc: {bans: 1}
        })