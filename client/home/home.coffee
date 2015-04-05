region = 'EUW'
Template.home.helpers 
	'first': () ->
		Champions.findOne({region: region},{sort: {winrate : -1}})
	'champions': () ->
		Champions.find({region: region},{sort: {winrate : -1}, limit: 10, skip: 1 })
	'winrate': (winrate) ->
		winrate = Champions.findOne({region: region},{sort: {winrate : -1}}).winrate
		winrate = parseInt(winrate*100)
		winrate
	'kda': (champion) ->
		games = champion.wins + champion.losses
		kills = parseInt(champion.kills/games)
		deaths = parseInt(champion.deaths/games)
		assists = parseInt(champion.assists/games)
		kills+'/'+deaths+'/'+assists


Template.champion.rendered = () ->
	$('.count').each (number) ->
		$(this).text('#'+(number+1))

Template.champion.helpers
	'winrate': () ->
		# wins = this.wins
		# losses = this.losses
		# total = wins + losses
		# winrate = (wins/total)*100
		parseInt(this.winrate*100)

	'kda': () ->
		games = this.wins + this.losses
		kills = parseInt(this.kills/games)
		deaths = parseInt(this.deaths/games)
		assists = parseInt(this.assists/games)
		kills+'/'+deaths+'/'+assists
