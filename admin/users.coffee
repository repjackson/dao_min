if Meteor.isClient
    Router.route '/users/', (->
        @layout 'admin_layout'
        @render 'users'
        ), name:'users'

    Template.profiles.onCreated ->
        @autorun => Meteor.subscribe 'profiles'

    Router.route '/profiles', -> @render 'profiles'
    Template.profiles.helpers
        profiles: ->
            username_query = Session.get('username_query')
            if username_query and username_query.length > 0
                Meteor.users.find({
                    username: {$regex:"#{username_query}", $options: 'i'}
                    },{ limit:20 })
            else
                Meteor.users.find({
                    },{ limit:20 })
    Template.profiles.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        'keyup .username_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query


    Template.users.onCreated ->
        @autorun -> Meteor.subscribe('users')
        # @autorun => Meteor.subscribe 'user_search', Session.get('username_query'), 'user'
    Template.users.helpers
        users: ->
            limit = Session.get('limit')
            username_query = Session.get('username_query')
            if username_query and username_query.length > 0
                Meteor.users.find({
                    username: {$regex:"#{username_query}", $options: 'i'}
                    # healthclub_checkedin:$ne:true
                    # roles:$in:['student','teacher']
                    },{ limit:20 }).fetch()
            else
                Meteor.users.find({
                    # username: {$regex:"#{username_query}", $options: 'i'}
                    # healthclub_checkedin:$ne:true
                    # roles:$in:['student','teacher']
                    },{ limit:20 }).fetch()
    Template.users.events
        'click .remove_user': ->
            console.log @
            if confirm "delete #{@username}? cannot be undone"
                Meteor.users.remove @_id
                alert "#{@username} deleted"
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        'keyup .username_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query


if Meteor.isServer
    Meteor.publish 'users', (limit)->
        if limit
            Meteor.users.find({},limit:limit)
        else
            Meteor.users.find()


    Meteor.publish 'profiles', ()->
        Meteor.users.find
            roles:$in:['student']
            profile_published:true


    Meteor.publish 'user_search', (username, role)->
        if role
            if username
                Meteor.users.find({
                    username: {$regex:"#{username}", $options: 'i'}
                    roles:$in:[role]
                },{ limit:20})
            else
                Meteor.users.find({
                    # username: {$regex:"#{username}", $options: 'i'}
                    roles:$in:[role]
                },{ limit:20})
        else
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
            },{ limit:20})
