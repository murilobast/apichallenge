FlowRouter.route '/',
    action: () ->
        Meta.setTitle("Home")
        Session.set 'title', "Home"
        Session.set 'first', {key: 'Katarina'}
        FlowLayout.render('layout', { main: "home" })

FlowRouter.route '/stats',
    action: () ->
        Meta.setTitle("Stats")
        Session.set 'title', "Stats"
        Session.set 'first', {key: 'Katarina'}
        FlowLayout.render('layout', { main: "stats" })

FlowRouter.route '/wins/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            winrate : -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 15, 0
    action: (params) ->
        server = params.server.toUpperCase()
        Meta.setTitle("Win Rate " + server)
        Session.set 'title', "Highest win rate " + server
        Session.set 'type', "wins"
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/losses/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            winrate : 1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 15, 0
    action: (params) ->
        server = params.server.toUpperCase()
        Meta.setTitle("Worst Win Rate" + server)
        Session.set 'title', "Lowest win rate " + server
        Session.set 'type', "losses"
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/bans/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            bans: -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 15, 0
    action: (params) ->
        server = params.server.toUpperCase()
        Meta.setTitle("Most Banned" + server)
        Session.set 'title', "Most banned champions " + server
        Session.set 'type', "bans"
        FlowLayout.render('layout', { main: "display" })

FlowRouter.route '/picks/:server',
    subscriptions: (params) ->
        server = params.server.toUpperCase()
        sort = {
            games: -1
        }
        @register 'champions', Meteor.subscribe 'champions', server, sort, 15, 0
    action: (params) ->
        server = params.server.toUpperCase()
        Meta.setTitle("Most Played" + server)
        Session.set 'title', "Most played champions " + server
        Session.set 'type', "picks"
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
        zindex: 1240,
        cursorcolor: '#fff',
        cursoropacitymin: 0.05,
        cursoropacitymax: 0.3,
        cursorborder: 0,
        cursorborderradius: 0,
        mousescrollstep: 60
    })
    $('#select-server').selectize({
    })


Handlebars.registerHelper 'session', (input) ->
    Session.get(input);

Meta.config
    options:
        title: "SITENAME"
        suffix: "Urf"



# date = new Date
# dateFlat = new Date
# dateFlat.setMinutes(Math.round(dateFlat.getMinutes()/5) * 5) % 60
# dateFlat.setSeconds(0)
# if dateFlat.getMinutes() > date.getMinutes()
#     dateFlat.setMinutes(dateFlat.getMinutes - 5)
# date = Number(dateFlat).toString().slice(0,-3)