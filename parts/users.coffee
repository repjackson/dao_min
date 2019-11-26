if Meteor.isClient
    Router.route '/users/', (->
        @layout 'layout'
        @render 'users'
        ), name:'users'

    Template.users.onRendered ->

    Template.users.onCreated ->
        @autorun -> Meteor.subscribe 'users'
    Template.users.helpers
        users: ->
            Meteor.users.find()


if Meteor.isServer
    Meteor.publish 'users', ->
        Meteor.users.find()
