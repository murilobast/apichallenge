region = 'BR'
Template.display.helpers 
	'first': () ->
		first = Champions.findOne()
		Session.set 'first', first
		first
	'champions': () ->
		Champions.find({},{skip: 1})
	'winrate': (winrate) ->
		winrate = Champions.findOne().winrate
		winrate = parseInt(winrate*100)
		winrate
	'kda': (champion) ->
		games = champion.wins + champion.losses
		kills = parseInt(champion.kills/games)
		deaths = parseInt(champion.deaths/games)
		assists = parseInt(champion.assists/games)
		kills+'/'+deaths+'/'+assists

Template.display.events
	'click .content__body__featured__more': () ->
		$('.blankscreen').css('display', 'block')
		modal = $('.modal')
		if modal.css('top') == '-3000px'
			modal.css('top', '1px')
		Session.set 'info', Session.get 'first'

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

Template.champion.events
	'click .openModal': () ->
		$('.blankscreen').css('display', 'block')
		modal = $('.modal')
		if modal.css('top') == '-3000px'
			modal.css('top', '1px')
		Session.set 'info', this

Template.infoModal.helpers
	'getInfo': () ->
		Session.get 'info'
	'parseWinrate': (winrate) ->
		parseInt(winrate*100)

Template.infoModal.events
	'click .close': () ->
		$('.blankscreen').css('display', 'none')
		modal = $('.modal')
		if modal.css('top') == '1px'
			modal.css('top', '-3000px')