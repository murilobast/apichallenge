Template.side.helpers
	'active': (type) ->
		if type == Session.get 'type'
			'active'

Template.side.events
	'click a': (evt, tmpl) ->
		name = evt.currentTarget.name
		server = tmpl.find('#select-server').value
		console.log server
		FlowRouter.go('/'+name+'/'+server)