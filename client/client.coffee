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

FlowRouter.route '/bans/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            bans: -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 10, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/picks/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            games: -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 10, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })

Template.layout.helpers
    'isReady': (sub) ->
        if sub
            FlowRouter.subsReady(sub)
        else
            FlowRouter.subsReady()
    'firstChamp': ->
        bg = Session.get 'first'
        bg.key

Template.body.rendered = () ->
    $("html").niceScroll({
        zindex: 100,
        cursorcolor: '#fff',
        cursoropacitymin: 0.05,
        cursoropacitymax: 0.3,
        cursorborder: 0,
        cursorborderradius: 0,
        mousescrollstep: 60
    })