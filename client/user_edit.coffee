Router.route '/user/:user_id/edit/', (->
    @layout 'user_edit_layout'
    @render 'user_edit_info'
    ), name:'user_edit_home'
Router.route '/user/:user_id/edit/info', (->
    @layout 'user_edit_layout'
    @render 'user_edit_info'
    ), name:'user_edit_info'
Router.route '/user/:user_id/edit/account', (->
    @layout 'user_edit_layout'
    @render 'user_edit_account'
    ), name:'user_edit_account'

Template.user_edit_layout.onCreated ->
    @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.username

Template.user_edit_layout.onRendered ->
    Meteor.setTimeout ->
        $('.button').popup()
    , 2000



Template.user_edit_layout.events
    'click .remove_user': ->
        if confirm "confirm delete #{@username}?  cannot be undone."
            Meteor.users.remove @_id
            Router.go "/users"


Template.username_edit.events
    'click .change_username': (e,t)->
        new_username = t.$('.new_username').val()
        current_user = Meteor.users.findOne Router.current().params.user_id
        if new_username
            if confirm "change username from #{current_user.username} to #{new_username}?"
                Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                    if err
                        alert err
                    else
                        Router.go("/user/#{new_username}")




Template.password_edit.helpers
    passwords_matching: ->
        if Session.get('old_password') and Session.get('old_password').length > 3
            Session.get('new_password') and Session.get('new_password').length > 3


Template.password_edit.events
    'keyup #old_password': ->
        old_password = $('#old_password').val()
        Session.set 'old_password', old_password

    'keyup #new_password': ->
        new_password = $('#new_password').val()
        Session.set 'new_password', new_password

    'click .change_password': (e, t) ->
        Accounts.changePassword $('#old_password').val(), $('#new_password').val(), (err, res) ->
            if err
                alert err.reason
            else
                alert 'password changed'
                # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

    'click .set_password': (e, t) ->
        new_password = $('#new_password').val()
        current_user = Meteor.users.findOne Router.current().params.user_id
        Meteor.call 'set_password', current_user._id, new_password, ->
            alert "password set to #{new_password}."
