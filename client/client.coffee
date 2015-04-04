FlowRouter.route '/',
    subscriptions: ->
        @register 'champions', Meteor.subscribe 'champions'
    action: ->
        FlowLayout.render('home')