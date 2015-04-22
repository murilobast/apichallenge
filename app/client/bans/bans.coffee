showModal = (info) ->
	blankscreen = $('.blankscreen')
	blankscreen.css('display', 'block')
	blankscreen.addClass('fadeIn')
	modal = $('.modal')
	if modal.css('display') == 'none'
		modal.css('top', '1px')
		modal.css('display', 'block')
		modal.addClass('fadeIn')
	Session.set 'info', info

Template.bans.helpers 
	'first': ->
		first = this[0]
		Session.set 'first', first
		first
	'champions': ->
		this.shift()
		this
	'banRate': (banRate) ->
		banRate = Session.get('first').banRate
		banRate = parseInt(banRate*100)
		banRate

Template.bans.events
	'click .content__body__featured__more': ->
		showModal(Session.get 'first')

Template.bansChampion.rendered = ->
	$('.count').each (number) ->
		$(this).text('#'+(number+1))

Template.bansChampion.helpers
	'banRate': ->
		parseInt(this.banRate*100)

	'kda': ->
		games = this.wins + this.losses
		kills = parseInt(this.kills/games)
		deaths = parseInt(this.deaths/games)
		assists = parseInt(this.assists/games)
		kills+'/'+deaths+'/'+assists

Template.bansChampion.events
	'click .openModal': ->
		showModal(@)