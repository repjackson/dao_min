if Meteor.isClient
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
            username = $('.username').val()
            Meteor.call 'find_username', username, (err,res)->
                console.log res
                if res
                    Session.set 'username_status', 'invalid'
                else
                    Session.set 'username_status', 'valid'

        'keyup .password': ->
            password = $('.password').val()
            Session.set 'password', password
            password = $('.password').val()


            # Meteor.call 'find_username', username, (err,res)->
            #     if res
            #         Session.set 'enter_mode', 'login'
            #     else
            #         Session.set 'enter_mode', 'register'
        'click .enter': (e,t)->
            username = $('.username').val()
            password = $('.password').val()
            # if Session.equals 'enter_mode', 'register'
            # if confirm "register #{username}?"
            # Meteor.call 'validate_username', username, (err,res)->
            #     console.log res
            options = {
                username:username
                password:password
                }
            Meteor.call 'create_user', options, (err,res)=>
                console.log res
                Meteor.users.update res,
                    $addToSet: roles: 'user'
                Meteor.loginWithPassword username, password, (err,res)=>
                    if err
                        alert err.reason
                        # if err.error is 403
                        #     Session.set 'message', "#{username} not found"
                        #     Session.set 'enter_mode', 'register'
                        #     Session.set 'username', "#{username}"
                    else
                        Router.go "/"
                        # Meteor.call 'generate_trans_types', new_classroom_id, ->
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
            Session.equals('username_status', 'valid') and Session.get('password')
        username: -> Session.get 'username'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
        username_valid: ->
            Session.equals 'username_status', 'valid'
        username_invalid: ->
            Session.equals 'username_status', 'invalid'
        can_submit: ->
            username = Session.get 'username'
            username = Session.get 'username'
            password = Session.get 'password'
            password2 = Session.get 'password2'
            if username and username
                if password.length > 0 and password is password2
                    true
                else
                    false


if Meteor.isServer
    Meteor.methods
        set_user_password: (user, password)->
            result = Accounts.setPassword(user._id, password)
            console.log result
            result

        # verify_username: (username)->
        #     (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(username))




        create_user: (options)->
            console.log 'creating user', options
            Accounts.createUser options

        find_username: (username)->
            res = Accounts.findUserByUsername(username)
            if res
                # console.log res
                unless res.disabled
                    return res

        new_demo_user: ->
            current_user_count = Meteor.users.find().count()

            options = {
                username:"user#{current_user_count}"
                password:"user#{current_user_count}"
                }

            create = Accounts.createUser options
            new_user = Meteor.users.findOne create
            return new_user
