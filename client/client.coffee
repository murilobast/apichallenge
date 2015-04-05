FlowRouter.route '/wins/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            winrate : -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 20, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/loss/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            winrate : 1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 20, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/bans/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            bans: -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 20, 0
    action: ->
        FlowLayout.render('layout', { main: "display" })

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