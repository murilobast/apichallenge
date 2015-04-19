request = require("request")
MongoClient = require('mongodb').MongoClient
assert = require('assert')

#Info
apiKey = #API KEY
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
timestamp = 1428918000
testCount = 1

# Connection URL 
url = 'mongodb://localhost:3001/meteor'
# Use connect method to connect to the Server 
MongoClient.connect url, (err, db) ->
    assert.equal null, err
    console.log 'Connected correctly to server'
    setInterval (->
        if timestamp > 1427865900
            for region in regions
                getMatchIds(db, region)
        else
            console.log 'please stop the script'
        timestamp = timestamp-300
        ), 5000

getMatchIds = (db, region) ->
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v4.1/game/ids?beginDate=' + timestamp + '&api_key=' + apiKey
    regionUpper = region.toUpperCase()
    request url, {json: true}, (err, res, body) ->
        if not err
            if res.statusCode == 200
                console.log "GOT MATCHID'S FOR: "+regionUpper+' - TIMESTAMP: '+(timestamp+300) #Compensation for async
                matchIds = body
                if matchIds.length != 0
                    for matchId in matchIds
                        getMatches(db, region, regionUpper, matchId)
            else
                console.log "GET MATCHID'S - ERROR - "+'REGION: '+regionUpper+" - STATUSCODE: "+res.statusCode+' - TIMESTAMP: '+(timestamp+300)
        else
            console.log err

getMatches = (db, region, regionUpper, matchId) ->
    url = 'https://' + region + '.api.pvp.net/api/lol/' + region + '/v2.2/match/' + matchId + '?includetimestampline=false&api_key=' + apiKey
    request url, {json: true}, (err, res, body) ->
        if not err
            if res.statusCode == 200
                #console.log 'GOT MATCH FROM MATCHID: '+matchId+' - REGION: '+regionUpper
                insertMatches(db, regionUpper, body)
            else
                console.log "GET MATCH - ERROR - "+'REGION: '+regionUpper+" - STATUSCODE: "+res.statusCode+' - TIMESTAMP: '+(timestamp+300)
        else
            console.log err

insertMatches = (db, regionUpper, matchData) ->
    # Get the documents collection 
    Matches = db.collection('matches')
    # Insert some documents
    #Sometimes the timestamp compensation can fail
    console.log testCount+' - INSERTING MATCHDATA - REGION: '+regionUpper+' - TIMESTAMP: '+(timestamp+300)+' - MATCHID: '+matchData.matchId
    Matches.insert matchData, (err, result) ->
        assert.equal err, null
        testCount++