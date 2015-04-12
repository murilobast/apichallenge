timestamp = getTime()

Meteor.setInterval (->
    for region in regions
        getMatchIdsNew(region, timestamp)
        timestamp = timestamp-300
    ), 6000

getMatchIdsNew = (thisregion, thistimestamp) ->
    url = 'https://' + thisregion + '.api.pvp.net/api/lol/' + thisregion + '/v4.1/game/ids?beginDate=' + thistimestamp + '&api_key=' + apiKey
    regionUpper = thisregion.toUpperCase()
    HTTP.get url, (err, result) ->
        if not err
            if result.statusCode == 200
                console.log "GOT MATCHID'S FOR: "+regionUpper+' - TIMESTAMP: '+thistimestamp
                matchIds = result.data
                if matchIds.length != 0
                    for matchId in matchIds
                        getMatchData(thisregion, regionUpper, matchId)
            else
                console.log "GET MATCHID'S - ERROR - STATUSCODE: "+matchIds.statusCode
        else
            console.log err

getMatchData = (this2region, this2regionUpper, this2matchId) ->
    url = 'https://' + this2region + '.api.pvp.net/api/lol/' + this2region + '/v2.2/match/' + this2matchId + '?includetimestampline=true&api_key=' + apiKey
    HTTP.get url, (err, result) ->
        if not err
            if result.statusCode == 200
                matchData = result.data
                matchId = matchData.matchId
                if Matches.findOne({region: this2regionUpper, matchId: matchId})
                    console.log 'FOUND MATCH: '+matchId+' - REGION: '+this2regionUpper+' -- SKIPING'
                else
                    console.log 'INSERTING MATCH: '+matchId+' - REGION: '+this2regionUpper
                    Matches.insert(matchData)
            else
                console.log 'GET MATCH - ERROR - STATUSCODE: '+result.statusCode
        else
            console.log err