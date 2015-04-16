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

hideModal = () ->
	blankscreen = $('.blankscreen')
	blankscreen.css('display', 'none')
	modal = $('.modal')
	if modal.css('display') == 'block'
		modal.css('top', '1px')
		modal.css('display', 'none')

Template.display.helpers 
	'first': ->
		first = this[0]
		Session.set 'first', first
		first
	'champions': ->
		this.shift()
		this
	'winRate': (winRate) ->
		winRate = Session.get('first').winRate
		winRate = parseInt(winRate*100)
		winRate
	'kda': (champion) ->
		games = champion.wins + champion.losses
		kills = parseInt(champion.kills/games)
		deaths = parseInt(champion.deaths/games)
		assists = parseInt(champion.assists/games)
		kills+'/'+deaths+'/'+assists

Template.display.events
	'click .content__body__featured__more': ->
		showModal(Session.get 'first')

Template.champion.rendered = ->
	$('.count').each (number) ->
		$(this).text('#'+(number+1))
	
Template.champion.helpers
	'winRate': ->
		parseInt(this.winRate*100)
	'kda': ->
		games = this.wins + this.losses
		kills = parseInt(this.kills/games)
		deaths = parseInt(this.deaths/games)
		assists = parseInt(this.assists/games)
		kills+'/'+deaths+'/'+assists

Template.champion.events
	'click .openModal': ->
		showModal(@)

Template.infoModal.rendered = () ->
	 $(".modal__body__stats").niceScroll({
        zindex: 1240,
        cursorcolor: '#fff',
        cursoropacitymin: 0.05,
        cursoropacitymax: 0.3,
        cursorborder: 0,
        cursorborderradius: 0,
        mousescrollstep: 30
    })

Template.infoModal.helpers
	'getInfo': ->
		Session.get 'info'
	'parseWinrate': (winrate) ->
		parseInt(winrate*100)
	'getKDA': (champion) ->
		if champion
			games = champion.wins + champion.losses
			kills = parseInt(champion.kills/games)
			deaths = parseInt(champion.deaths/games)
			assists = parseInt(champion.assists/games)
			kills+'/'+deaths+'/'+assists
	'getInteger': (val) ->
		parseInt(val)
		
Template.infoModal.events
	'click .close': ->
		hideModal()