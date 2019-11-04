if Meteor.isClient
    Router.route '/ruser/:rusername', (->
        @layout 'layout'
        @render 'ruser_view'
        ), name:'ruser_view'


    Template.ruser_view.onCreated ->
        @autorun => Meteor.subscribe 'ruser', Router.current().params.rusername
    Template.ruser_view.helpers
        current_ruser: ->
            Docs.findOne
                model:'ruser'
                rusername:Router.current().params.rusername

    Template.ruser_view.events
        'click .pull_user': ->
            username = Router.current().params.rusername
            Meteor.call 'get_reddit_user', username



if Meteor.isServer
    Meteor.publish 'ruser', (rusername)->
        Docs.find
            model:'ruser'
            rusername:rusername
