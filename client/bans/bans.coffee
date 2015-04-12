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

Template.bans.rendered = () ->
	region = Session.get 'region'
	sort = Session.get 'sort'
	Meteor.subscribe 'champions', region, sort, 15, 0

Template.bans.helpers 
	'first': ->
		first = Champions.findOne()
		Session.set 'first', first
		first
	'champions': ->
		Champions.find({},{skip: 1})
	'banrate': (banrate) ->
		banrate = Champions.findOne().banrate
		banrate = parseInt(banrate*100)
		banrate

Template.bans.events
	'click .content__body__featured__more': ->
		showModal(Session.get 'first')

Template.bansChampion.rendered = ->
	$('.count').each (number) ->
		$(this).text('#'+(number+1))

Template.bansChampion.helpers
	'banrate': ->
		parseInt(this.banrate*100)

	'kda': ->
		games = this.wins + this.losses
		kills = parseInt(this.kills/games)
		deaths = parseInt(this.deaths/games)
		assists = parseInt(this.assists/games)
		kills+'/'+deaths+'/'+assists

Template.bansChampion.events
	'click .openModal': ->
		showModal(@)