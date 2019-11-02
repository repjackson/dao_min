if Meteor.isClient
    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'current_session'
        # @autorun -> Meteor.subscribe 'unread_messages'

    Template.nav.helpers
    Template.nav.events
        'click .add_doc': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go "/m/post/#{new_id}/edit"
        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'

        'click .spinning': ->
            Session.set 'loading', false



    Template.mlayout.onCreated ->
        @autorun -> Meteor.subscribe 'me'

if Meteor.isServer
    Meteor.publish 'me', ->
        Meteor.users.find @userId
