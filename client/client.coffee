# FlowRouter.route '/',
#     action: () ->
#         Meta.setTitle("Home")
#         Session.set 'title', "Home"
#         Session.set 'first', {key: 'Katarina'}
#         FlowLayout.render('layout', { main: "home" })

# FlowRouter.route '/stats',
#     action: () ->
#         Meta.setTitle("Stats")
#         Session.set 'title', "Stats"
#         Session.set 'first', {key: 'Katarina'}
#         FlowLayout.render('layout', { main: "stats" })

# FlowRouter.route '/wins/:server',
#     subscriptions: (params) ->
#         server = params.server.toUpperCase()
#         sort = {
#             winrate : -1
#         }
#         @register 'wins', Meteor.subscribe 'champions', server, sort, 15, 0
#     action: (params) ->
#         server = params.server.toUpperCase()
#         Meta.setTitle("Win Rate " + server)
#         Session.set 'title', "Highest win rate " + server
#         Session.set 'type', "wins"
#         FlowLayout.render('layout', { main: "display" })

Router.route '/wins/:region', 
    waitOn: ->
        region = this.params.region.toUpperCase()
        Meteor.subscribe 'wins', region, 15, 0
    onBeforeAction: (pause) ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Win Rate " + region)
        Session.set 'title', "Highest win rate " + region
        Session.set 'type', "wins"
        this.next()
    action: ->
        if this.ready()
            this.render 'display'

Router.route '/losses/:region', 
    waitOn: ->
        region = this.params.region.toUpperCase()
        Meteor.subscribe 'losses', region, 15, 0
    onBeforeAction: (pause) ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Lowest win rate " + region)
        Session.set 'title', "Lowest win rate " + region
        Session.set 'type', "losses"
        this.next()
    action: ->
        if this.ready()
            this.render 'display'

Router.route '/picks/:region', 
    waitOn: () ->
        region = this.params.region.toUpperCase()
        Meteor.subscribe 'champions', region, 15, 0
    onBeforeAction: (pause) ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Most picked " + region)
        Session.set 'title', "Most picked champion " + region
        Session.set 'type', "picks"
        this.next()
    action: ->
        if this.ready()
            this.render 'picks'

Router.route '/bans/:region', 
    waitOn: ->
        region = this.params.region.toUpperCase()
        Meteor.subscribe 'champions', region, 15, 0
    onBeforeAction: (pause) ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Most banned " + region)
        Session.set 'title', "Most banned champion " + region
        Session.set 'type', "bans"
        this.next()
    action: ->
        if this.ready()
            this.render 'bans'
# FlowRouter.route '/losses/:server',
#     subscriptions: (params) ->
#         server = params.server.toUpperCase()
#         sort = {
#             lossrate : -1
#         }
#         @register 'losses', Meteor.subscribe 'champions', server, sort, 15, 0
#     action: (params) ->
#         server = params.server.toUpperCase()
#         Meta.setTitle("Worst Win Rate" + server)
#         Session.set 'title', "Lowest win rate " + server
#         Session.set 'type', "losses"
#         FlowLayout.render('layout', { main: "display" })

# FlowRouter.route '/bans/:server',
#     subscriptions: (params) ->
#         server = params.server.toUpperCase()
#         sort = {
#             banrate: -1
#         }
#         @register 'bans', Meteor.subscribe 'champions', server, sort, 15, 0
#     action: (params) ->
#         server = params.server.toUpperCase()
#         Meta.setTitle("Most Banned" + server)
#         Session.set 'title', "Most banned champions " + server
#         Session.set 'type', "bans"
#         FlowLayout.render('layout', { main: "bans" })

# FlowRouter.route '/picks/:server',
#     subscriptions: (params) ->
#         server = params.server.toUpperCase()
#         sort = {
#             pickrate: -1
#         }
#         @register 'picks', Meteor.subscribe 'champions', server, sort, 15, 0
#     action: (params) ->
#         server = params.server.toUpperCase()
#         Meta.setTitle("Most Played" + server)
#         Session.set 'title', "Most played champions " + server
#         Session.set 'type', "picks"
#         FlowLayout.render('layout', { main: "picks" })
Template.body.helpers
    'firstChamp': ->
        bg = Session.get 'first'
        bg.key

# Template.layout.helpers
#     'isReady': (sub) ->
#         if sub
#             FlowRouter.subsReady(sub)
#         else
#             FlowRouter.subsReady()
#     'firstChamp': ->
#         bg = Session.get 'first'
#         bg.key

Template.body.rendered = () ->
    $('#select-server').selectize({
    })


Handlebars.registerHelper 'session', (input) ->
    Session.get(input);

Meta.config
    options:
        title: "SITENAME"
        suffix: "Urf"