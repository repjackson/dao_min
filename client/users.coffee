Router.route '/users/', (->
    @layout 'layout'
    @render 'users'
    ), name:'users'

Template.users.onRendered ->
Template.users.onCreated ->
    @autorun -> Meteor.subscribe 'users'
Template.users.helpers
    users: -> Meteor.users.find()




Router.route '/register', (->
    @layout 'layout'
    @render 'register'
    ), name:'register'


Template.register.onCreated ->
    Session.set 'username', null
Template.register.events
    'keyup .username': ->
        username = $('.username').val()
        Session.set 'username', username
        Meteor.call 'find_username', username, (err,res)->
            if res
                Session.set 'enter_mode', 'login'
            else
                Session.set 'enter_mode', 'register'

    'blur .username': ->
        username = $('.username').val()
        Session.set 'username', username
        Meteor.call 'find_username', username, (err,res)->
            if res
                Session.set 'enter_mode', 'login'
            else
                Session.set 'enter_mode', 'register'

    'click .register': (e,t)->
        username = $('.username').val()
        # email = $('.email').val()
        password = $('.password').val()
        # if Session.equals 'enter_mode', 'register'
        # if confirm "register #{username}?"
        options = {
            username:username
            password:password
        }
        Meteor.call 'create_user', options, (err,res)=>
            console.log res
            Meteor.loginWithPassword username, password, (err,res)=>
                if err
                    alert err.reason
                    # if err.error is 403
                    #     Session.set 'message', "#{username} not found"
                    #     Session.set 'enter_mode', 'register'
                    #     Session.set 'username', "#{username}"
                else
                    # Meteor.users.update Meteor.userId(),
                    #     $set:
                    #         first_name: Session.get('first_name')
                    #         last_name: Session.get('last_name')
                    Router.go '/'
        # else
        #     Meteor.loginWithPassword username, password, (err,res)=>
        #         if err
        #             if err.error is 403
        #                 Session.set 'message', "#{username} not found"
        #                 Session.set 'enter_mode', 'register'
        #                 Session.set 'username', "#{username}"
        #         else
        #             Router.go '/'


Template.register.helpers
    can_register: ->
        # Session.get('first_name') and Session.get('last_name') and Session.get('email')
        Session.get('username')

    username: -> Session.get 'username'
    registering: -> Session.equals 'enter_mode', 'register'
    enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''




Template.user_up.onCreated ->
    @autorun -> Meteor.subscribe 'user_up_answers', Router.current().params.user_id
    @autorun -> Meteor.subscribe 'model_docs', 'question'
    @autorun -> Meteor.subscribe 'model_docs', 'union'
Template.user_up.helpers
    up_answers: ->
        Docs.find {
            upvoter_ids:$in:[Meteor.userId()]
        }, sort: _timestamp: -1

    union_doc: ->
        Docs.findOne
            model:'union'
            user_ids:$all:[Meteor.userId(), Router.current().params.user_id]
Template.user_up.events
    'click .calc_up_overlap': ->
        Meteor.call 'calc_user_up_cloud', Meteor.userId()
        Meteor.call 'calc_user_up_cloud', Router.current().params.user_id
        Meteor.call 'calc_up_union', Meteor.userId(), Router.current().params.user_id


Template.user_down.onCreated ->
    @autorun -> Meteor.subscribe 'user_down_answers', Router.current().params.user_id
    @autorun -> Meteor.subscribe 'model_docs', 'question'
    @autorun -> Meteor.subscribe 'model_docs', 'union'
Template.user_down.helpers
    down_answers: ->
        Docs.find {
            downvoter_ids:$in:[Meteor.userId()]
        }, sort: _timestamp: -1

    union_doc: ->
        Docs.findOne
            model:'union'
            user_ids:$all:[Meteor.userId(), Router.current().params.user_id]
Template.user_down.events
    'click .calc_down_overlap': ->
        Meteor.call 'calc_user_down_cloud', Meteor.userId()
        Meteor.call 'calc_user_down_cloud', Router.current().params.user_id
        Meteor.call 'calc_down_union', Meteor.userId(), Router.current().params.user_id
