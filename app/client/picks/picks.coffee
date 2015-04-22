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

Template.picks.helpers 
	'first': ->
		first = this[0]
		Session.set 'first', first
		first
	'champions': ->
		this.shift()
		this
	'pickRate': (pickRate) ->
		pickRate = Session.get('first').pickRate
		pickRate = parseInt(pickRate*100)
		pickRate

Template.picks.events
	'click .content__body__featured__more': ->
		showModal(Session.get 'first')

Template.picksChampion.rendered = ->
	$('.count').each (number) ->
		$(this).text('#'+(number+1))

Template.picksChampion.helpers
	'pickRate': ->
		parseInt(this.pickRate*100)

	'kda': ->
		games = this.wins + this.losses
		kills = parseInt(this.kills/games)
		deaths = parseInt(this.deaths/games)
		assists = parseInt(this.assists/games)
		kills+'/'+deaths+'/'+assists

Template.picksChampion.events
	'click .openModal': ->
		showModal(@)