Router.route '/', 
    waitOn: ->
        Meta.setTitle("Home".toUpperCase())
        Session.set 'title', "Home"
        Session.set 'type', "home"
        Session.set 'first', {key: 'Diana_2'}
        this.next()
    action: ->
        this.render 'home'

Router.route '/wins/:region', 
    waitOn: ->
            region = this.params.region.toUpperCase()
            Meteor.subscribe 'champions', region
    onBeforeAction: ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Highest win rate ".toUpperCase())
        Session.set 'title', "Highest win rate " + region
        Session.set 'type', "wins"
        this.next()
    action: ->
        this.render 'display', data: ->
            Champions.find({},{sort: {winRate: -1}, limit: 25}).fetch()

Router.route '/losses/:region', 
    waitOn: ->
            region = this.params.region.toUpperCase()
            Meteor.subscribe 'champions', region
    onBeforeAction: ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Lowest win rate".toUpperCase())
        Session.set 'title', "Lowest win rate " + region
        Session.set 'type', "losses"
        this.next()
    action: ->
        this.render 'display', data: ->
            Champions.find({},{sort: {winRate: 1}, limit: 25}).fetch()

Router.route '/picks/:region', 
    waitOn: ->
            region = this.params.region.toUpperCase()
            Meteor.subscribe 'champions', region
    onBeforeAction: ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Most picked".toUpperCase())
        Session.set 'title', "Most picked champion " + region
        Session.set 'type', "picks"
        this.next()
    action: ->
        this.render 'picks', data: ->
            Champions.find({},{sort: {games: -1}, limit: 25}).fetch()

Router.route '/bans/:region', 
    waitOn: ->
            region = this.params.region.toUpperCase()
            Meteor.subscribe 'champions', region
    onBeforeAction: ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Most banned".toUpperCase())
        Session.set 'title', "Most banned champion " + region
        Session.set 'type', "bans"
        this.next()
    action: ->
        this.render 'bans', data: ->
            Champions.find({},{sort: {bans: -1}, limit: 25}).fetch()

Router.route '/highestkd/:region', 
    waitOn: ->
            region = this.params.region.toUpperCase()
            Meteor.subscribe 'champions', region
    onBeforeAction: ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Highest KD".toUpperCase())
        Session.set 'title', "Highest KD ratio " + region
        Session.set 'type', "highestkd"
        this.next()
    action: ->
        this.render 'kd', data: ->
            Champions.find({},{sort: {KD: -1}, limit: 25}).fetch()

Router.route '/lowestkd/:region', 
    waitOn: ->
            region = this.params.region.toUpperCase()
            Meteor.subscribe 'champions', region
    onBeforeAction: ->
        region = this.params.region.toUpperCase()
        Meta.setTitle("Lowest KD".toUpperCase())
        Session.set 'title', "Lowest KD ratio " + region
        Session.set 'type', "lowestkd"
        this.next()
    action: ->
        this.render 'kd', data: ->
            Champions.find({},{sort: {KD: 1}, limit: 25}).fetch()
Template.body.helpers
    'firstChamp': ->
        if Session.get 'first'
            if Session.get('type') == "home"
                bg = Session.get 'first'
                bg.key
            else
                bg = Session.get 'first'
                bg.key + '_0'
            
Template.body.rendered = () ->
    $('#select-server').selectize()
    input = $('.selectize-input input')
    input.attr('disabled', true)

Handlebars.registerHelper 'session', (input) ->
    Session.get input

Meta.config
    options:
        title: "THIS IS"
        suffix: "LELKING"