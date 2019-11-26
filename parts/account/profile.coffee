if Meteor.isClient
    Router.route '/user/:user_id', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:user_id/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:user_id/finance', (->
        @layout 'profile_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:user_id/offers', (->
        @layout 'profile_layout'
        @render 'user_offers'
        ), name:'user_offers'
    Router.route '/user/:user_id/incorrect', (->
        @layout 'profile_layout'
        @render 'user_incorrect'
        ), name:'user_incorrect'
    Router.route '/user/:user_id/correct', (->
        @layout 'profile_layout'
        @render 'user_correct'
        ), name:'user_correct'
    Router.route '/user/:user_id/authored', (->
        @layout 'profile_layout'
        @render 'user_authored'
        ), name:'user_authored'
    Router.route '/user/:user_id/answered', (->
        @layout 'profile_layout'
        @render 'user_answered'
        ), name:'user_answered'
    Router.route '/user/:user_id/liked', (->
        @layout 'profile_layout'
        @render 'user_liked'
        ), name:'user_liked'
    Router.route '/user/:user_id/disliked', (->
        @layout 'profile_layout'
        @render 'user_disliked'
        ), name:'user_disliked'
    Router.route '/user/:user_id/yes', (->
        @layout 'profile_layout'
        @render 'user_yes'
        ), name:'user_yes'
    Router.route '/user/:user_id/no', (->
        @layout 'profile_layout'
        @render 'user_no'
        ), name:'user_no'
    Router.route '/user/:user_id/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:user_id/feed', (->
        @layout 'profile_layout'
        @render 'user_feed'
        ), name:'user_feed'


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
        @autorun -> Meteor.subscribe 'user_answered_questions', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_unanswered_questions', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_correct_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_incorrect_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_liked_questions', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_disliked_questions', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_no_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'user_yes_answers', Router.current().params.user_id


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
        unanswered_questions: ->
            Docs.find {
                model:'question'
                answered_user_ids: $nin:[Meteor.userId()]
            }, sort: _timestamp: -1
        incorrect_answers: ->
            Docs.find {
                model:'answer_session'
                is_correct_answer:false
                _author_id: Router.current().params.user_id
            }, sort: _timestamp: -1
        correct_answers: ->
            Docs.find {
                model:'answer_session'
                is_correct_answer:true
                _author_id: Router.current().params.user_id
            }, sort: _timestamp: -1
        no_answers: ->
            Docs.find {
                model:'answer_session'
                boolean_choice:false
                _author_id: Router.current().params.user_id
            }, sort: _timestamp: -1
        yes_answers: ->
            Docs.find {
                model:'answer_session'
                boolean_choice:true
                _author_id: Router.current().params.user_id
            }, sort: _timestamp: -1
        liked_questions: ->
            Docs.find {
                model:'question'
                upvoter_ids:$in:[Meteor.userId()]
            }, sort: _timestamp: -1
        disliked_questions: ->
            Docs.find {
                model:'question'
                downvoter_ids:$in:[Meteor.userId()]
            }, sort: _timestamp: -1
        user_models: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.profile_layout.events
        'click .profile_image': (e,t)->
            # $(e.currentTarget).closest('.profile_image').transition(
            #     animation: 'jiggle'
            #     duration: 750
            # )
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
    Meteor.publish 'user_liked_questions', (user_id)->
        Docs.find
            model:'question'
            upvoter_ids: $in: [user_id]
    Meteor.publish 'user_disliked_questions', (user_id)->
        Docs.find
            model:'question'
            downvoter_ids: $in: [user_id]
    Meteor.publish 'user_correct_answers', (user_id)->
        Docs.find
            model:'answer_session'
            _author_id: user_id
            is_correct_answer: true
    Meteor.publish 'user_incorrect_answers', (user_id)->
        Docs.find
            model:'answer_session'
            _author_id: user_id
            is_correct_answer: false
    Meteor.publish 'user_no_answers', (user_id)->
        Docs.find
            model:'answer_session'
            _author_id: user_id
            boolean_choice: false
    Meteor.publish 'user_yes_answers', (user_id)->
        Docs.find
            model:'answer_session'
            _author_id: user_id
            boolean_choice: true

    Meteor.publish 'user_stats', (user_id)->
        user = Meteor.users.findOne user_id
        if user
            Docs.find
                model:'user_stats'
                user_id:user._id
