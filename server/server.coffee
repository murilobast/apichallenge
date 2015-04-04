apiKey = Assets.getText 'apikey'
regions = ['br', 'eune', 'euw', 'kr', 'lan', 'las', 'na', 'oce', 'ru', 'tr']
timestamp = 1428098400

###For testing
Meteor.setInterval (->
		for region in regions
				getMatchIdsAndInsertMatches(region)
		), 10000
###

###For production
everyMinute = new Cron((->
	for region in regions
		getMatchIdsAndInsertMatches(region)
), {})###

#need to get this optimized for performance (right now it's sync, can't get async to work properly) and also we need number of bans in the champion object. Still need a way to update the documents.
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

for region in regions
    makeIChampionObj(region)

updateChampionObj = (region) ->
	regionUpper = region.toUpperCase()
	for match in Matches.find({region: regionUpper}).fetch()
		championRegion = match.region
		championLatestTimestamp = match.timestamp
		for participant in match.participants
			championId = participant.championId
			championKills = participant.stats.kills
			championAssists = participant.stats.assists
			championDeaths = participant.stats.deaths
			championWin = 0
			championLoss = 0
			console.log Champions.find({id: championId, region: championRegion}).count()
			if Champions.find({id: championId}).count() == 0
				url = 'https://global.api.pvp.net/api/lol/static-data/'+region+'/v1.2/champion/'+championId+'?champData=image&api_key='+apiKey
				championGet = HTTP.get url
				championData = championGet.data
				if participant.stats.winner == true
					championWin = 1
				else
					championLoss = 1
				champion = {
					region: championRegion
					id: championId
					name: championData.name
					key: championData.key
					title: championData.title
					kills: championKills
					assists: championAssists
					deaths: championDeaths
					wins: championWin
					losses: championLoss
					likes: []
					image: championData.image
					latestTimestamp: championLatestTimestamp
				}
				console.log 'INSERTING CHAMPION!'
				Champions.insert(champion)
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