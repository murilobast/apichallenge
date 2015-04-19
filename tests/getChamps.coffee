request = require("request")
MongoClient = require('mongodb').MongoClient
assert = require('assert')
testCount0 = 1
 
#Info
apiKey = #API KEY
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr', 'all']
 
 
# Connection URL 
url = 'mongodb://localhost:3001/meteor'
 
# Use connect method to connect to the Server 
MongoClient.connect url, (err, db) ->
    console.log 'Connected correctly to server'
    Matches = db.collection('matches').aggregate()
    getMatches = db.collection('matches')
    Champions = db.collection('champions')
    MatchesInfo = db.collection('matchinfo')
    # --- Run this first to insert champions
    #for region in regions
    #    url = 'https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion?api_key='+apiKey
    #    if region != 'all'
    #        getChampions(url, region, Champions)
    #    if region == "euw"
    #        makeChampionRegionAll(url, region, Champions)
    #
    # --- Run this after to update all champions
    #Matches.on 'data', (matchData) ->
    #    region = matchData.region
    #    regionUpper = region.toUpperCase()
    #    for participant in matchData.participants
    #        updateChampion(participant, regionUpper, Champions)
    #    getTeamsBanData(regionUpper, matchData, Champions)
    #    console.log 'UPDATED THIS MANY TIMES: '+testCount0
    #    testCount0++
    #
    # --- To update more stats
    #updateMore(Champions)
    #for region in regions
    #    regionUpper = region.toUpperCase()
    #    loopThroughMatches(Champions, getMatches, regionUpper)
        

loopThroughMatches = (Champions, getMatches, regionUpper) ->
    if regionUpper == "ALL"
        getMatches.find().count (err, regionMatches) ->
            if not err
                updatePickAndBanRates(Champions, regionUpper, regionMatches)
            else
                console.log  err
    else
        getMatches.find({ region: regionUpper }).count (err, regionMatches) ->
            if not err
                updatePickAndBanRates(Champions, regionUpper, regionMatches)
            else
                console.log  err
            
getChampions = (url, region, Champions) ->
    regionUpper = region.toUpperCase()
    request url, {json: true}, (err, res, body) ->
        champions = body.data
        for champion of champions
            champion = champions[champion]
            championData = {
                id: champion.id
                key: champion.key
                name: champion.name
                title: champion.title
                region: regionUpper
                kills: 0
                deaths: 0
                assists: 0
                doubleKills: 0
                tripleKills: 0
                quadraKills: 0
                pentaKills: 0
                unrealKills: 0
                totalDamageDealt: 0
                totalDamageTaken: 0
                wins: 0
                losses: 0
                games: 0
                bans: 0
            }
            console.log 'INSERTING CHAMPION: '+champion.name+' - REGION: '+regionUpper
            Champions.insert(championData)
 
makeChampionRegionAll = (url, region, Champions) ->
    regionUpper = region.toUpperCase()
    request url, {json: true}, (err, res, body) ->
        champions = body.data
        for champion of champions
            champion = champions[champion]
            championData = {
                id: champion.id
                key: champion.key
                name: champion.name
                title: champion.title
                region: 'ALL'
                kills: 0
                deaths: 0
                assists: 0
                doubleKills: 0
                tripleKills: 0
                quadraKills: 0
                pentaKills: 0
                unrealKills: 0
                totalDamageDealt: 0
                totalDamageTaken: 0
                wardsPlaced: 0
                wins: 0
                losses: 0
                games: 0
                bans: 0
            }
            console.log 'INSERTING CHAMPION: '+champion.name+' - REGION: ALL'
            Champions.insert(championData)
 
updateChampion = (participant, regionUpper, Champions) ->
    id = participant.championId
    kills = participant.stats.kills
    deaths = participant.stats.deaths
    assists = participant.stats.assists
    doubleKills = participant.stats.doubleKills
    tripleKills = participant.stats.tripleKills
    quadraKills = participant.stats.quadraKills
    pentaKills = participant.stats.pentaKills
    unrealKills = participant.stats.unrealKills
    wardsPlaced = participant.stats.wardsPlaced
    totalDamageDealt = participant.stats.totalDamageDealt
    totalDamageTaken = participant.stats.totalDamageTaken
    win = if participant.stats.winner == true then win = 1 else win = 0
    loss = if participant.stats.winner == false then loss = 1 else loss = 0
    championData = {
        kills: kills
        deaths: deaths
        assists: assists
        doubleKills: doubleKills
        tripleKills: tripleKills
        quadraKills: quadraKills
        pentaKills: pentaKills
        unrealKills: unrealKills
        totalDamageDealt: totalDamageDealt
        totalDamageTaken: totalDamageTaken
        wardsPlaced: wardsPlaced
        wins: win
        losses: loss
        games: 1
    }
    Champions.update({id: id, region: regionUpper},{$inc: championData})
    Champions.update({id: id, region: 'ALL'},{$inc: championData})
 
getTeamsBanData = (regionUpper, matchData, Champions) ->
    teamsBanDataResult = []
    if matchData.teams[0].bans != undefined
        for teamsBanData in matchData.teams[0].bans
            teamsBanDataResult.push(teamsBanData)
    if matchData.teams[1].bans != undefined
        for teamsBanData in matchData.teams[1].bans
            teamsBanDataResult.push(teamsBanData)
    if teamsBanDataResult.length > 0
        for teamsBanData in teamsBanDataResult
            addBansToEachChampion(regionUpper, teamsBanData, Champions)
 
addBansToEachChampion = (regionUpper, teamsBanData, Champions) ->
    championId = teamsBanData.championId
    Champions.update(id: championId, region: regionUpper, {
        $inc: {bans: 1}
    })
    Champions.update(id: championId, region: 'ALL', {
        $inc: {bans: 1}
    })
 
 
updateMore = (Champions) ->
    Champions.find().each (err, champion) ->
        if not err
            if champion
                console.log 'PROGRESS: '+testCount0
                testCount0++
                id = champion.id
                wins = champion.wins
                games = champion.games
                kills = champion.kills
                deaths = champion.deaths
                KD = kills/deaths
                wardsPlaced = champion.wardsPlaced
                winRate = wins/games
                dmgRate = champion.totalDamageDealt/games
                dmgTakenRate = champion.totalDamageTaken/games
                wardsPlacedRate = wardsPlaced/games
                Champions.update({id: id, region: champion.region}, {$set: {winRate, dmgRate, dmgTakenRate, KD, wardsPlacedRate}})
 
 
updatePickAndBanRates = (Champions, regionUpper, regionMatches) ->
    Champions.find({region: regionUpper}).each (err, champion) ->
        if not err
            if champion
                id = champion.id
                games = champion.games
                bans = champion.bans
                pickRate = games/regionMatches
                banRate = bans/regionMatches
                console.log "UPDATING CHAMPION: "+id+"'S PICK RATE AND BAN RATE - REGION: "+regionUpper
                Champions.update({id: id, region: champion.region}, {$set: {pickRate, banRate}})