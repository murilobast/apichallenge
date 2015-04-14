Template.side.rendered = () ->
	region = $('#select-server').val()
	Session.set 'region', region

Template.side.helpers
	'active': (type) ->
		if type == Session.get 'type'
			'active'
Template.side.events
	'click a': (evt, tmpl) ->
		name = evt.currentTarget.name
		server = tmpl.find('#select-server').value
		Router.go('/'+name+'/'+server)

	'change #select-server': (evt, tmpl) ->
		name = Session.get 'type'
		region = tmpl.find('#select-server').value
		Session.set 'region', region
		Router.go('/'+name+'/'+region)