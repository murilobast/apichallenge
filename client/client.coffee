FlowRouter.route '/',
    subscriptions: ->
        @register 'matches', Meteor.subscribe 'matches'
    action: ->
        FlowLayout.render('home')