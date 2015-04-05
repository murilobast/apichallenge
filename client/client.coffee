FlowRouter.route '/wins/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            winrate : -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 10, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/loss/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            winrate : 1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 10, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/pick/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            wins : -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 10, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })