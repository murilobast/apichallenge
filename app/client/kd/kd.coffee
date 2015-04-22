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

Template.kd.helpers 
	'first': ->
		first = this[0]
		Session.set 'first', first
		first
	'champions': ->
		this.shift()
		this
	'toFixed': (value) ->
		value.toFixed(2)

Template.kd.events
	'click .content__body__featured__more': ->
		showModal(Session.get 'first')

Template.kdChampion.rendered = ->
	$('.count').each (number) ->
		$(this).text('#'+(number+1))

Template.kdChampion.helpers
	'toFixed': (value) ->
		if value
			value.toFixed(2)

Template.kdChampion.events
	'click .openModal': ->
		showModal(@)