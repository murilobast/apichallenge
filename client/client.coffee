FlowRouter.route '/',
    subscriptions: ->
        @register 'champions', Meteor.subscribe 'champions'
    action: ->
        FlowLayout.render('layout', { main: "home" })