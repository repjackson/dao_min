if Meteor.isClient
    Router.route '/user/:user_id', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:user_id/up', (->
        @layout 'profile_layout'
        @render 'user_up'
        ), name:'user_up'
    Router.route '/user/:user_id/down', (->
        @layout 'profile_layout'
        @render 'user_down'
        ), name:'user_down'
    Router.route '/user/:user_id/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'


    Template.profile_layout.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'classroom'
    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_stats', Router.current().params.user_id
    Template.profile_layout.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 2000
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.profile_layout.helpers
        user: ->
            Meteor.users.findOne Router.current().params.user_id
        ssd: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.findOne
                model:'user_stats'
                user_id:user._id

    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'user_up_questions', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_down_questions', Router.current().params.user_id


    Template.profile_layout.events
        'click .recalc_stats': ->
            Meteor.call 'calc_user_stats', Router.current().params.user_id


    Template.user_dashboard.helpers
        ssd: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.findOne
                model:'user_stats'
                user_id:user._id

        user_classrooms: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'classroom'
                user_ids: $in: [user._id]
        answered_questions: ->
            Docs.find {
                model:'question'
                answered_user_ids: $in:[Meteor.userId()]
            }, sort: _timestamp: -1
        up_questions: ->
            Docs.find {
                model:'question'
                upvoter_ids:$in:[Meteor.userId()]
            }, sort: _timestamp: -1
        down_questions: ->
            Docs.find {
                model:'question'
                downvoter_ids:$in:[Meteor.userId()]
            }, sort: _timestamp: -1
        user_models: ->


    Template.profile_layout.events
        'click .recalc_user_stats': ->
            Meteor.call 'recalc_user_stats', Router.current().params.user_id
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()
        'click .logout': ->
            Session.set 'logging_out', true
            Router.go '/login'
            Meteor.logout()
            Session.set 'logging_out', false








if Meteor.isServer
    Meteor.publish 'user_answered_questions', (user_id)->
        Docs.find
            model:'question'
            answered_user_ids: $in: [user_id]
    Meteor.publish 'user_unanswered_questions', (user_id)->
        Docs.find
            model:'question'
            answered_user_ids: $nin: [user_id]
    Meteor.publish 'user_up_questions', (user_id)->
        Docs.find
            model:'question'
            upvoter_ids: $in: [user_id]
    Meteor.publish 'user_down_questions', (user_id)->
        Docs.find
            model:'question'
            downvoter_ids: $in: [user_id]

    Meteor.publish 'user_stats', (user_id)->
        user = Meteor.users.findOne user_id
        if user
            Docs.find
                model:'user_stats'
                user_id:user._id
