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
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: ->
            Meteor.users.findOne Router.current().params.user_id
        user_sections: ->
            Docs.find {
                model:'user_section'
            }, sort:title:1
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
            $(e.currentTarget).closest('.profile_image').transition(
                animation: 'jiggle'
                duration: 750
            )

        'click .toggle_size': ->
            Session.set 'view_side', !Session.get('view_side')
        'click .recalc_user_stats': ->
            Meteor.call 'recalc_user_stats', Router.current().params.user_id
        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()






    Template.user_actions.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'user_action'
    Template.user_actions.helpers
        user_actions: ->
            Docs.find
                model:'user_action'







if Meteor.isServer
    Meteor.publish 'user_events', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'classroom_event'
            user_id:user._id

    Meteor.publish 'user_answered_questions', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'question'
            answered_user_ids: $in: [user_id]
    Meteor.publish 'user_unanswered_questions', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'question'
            answered_user_ids: $nin: [user_id]
    Meteor.publish 'user_liked_questions', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'question'
            upvoter_ids: $in: [user_id]
    Meteor.publish 'user_disliked_questions', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'question'
            downvoter_ids: $in: [user_id]
    Meteor.publish 'user_correct_answers', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'answer_session'
            _author_id: user_id
            is_correct_answer: true
    Meteor.publish 'user_incorrect_answers', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'answer_session'
            _author_id: user_id
            is_correct_answer: false

    Meteor.publish 'user_stats', (user_id)->
        user = Meteor.users.findOne user_id
        if user
            Docs.find
                model:'user_stats'
                user_id:user._id


    Meteor.methods
        recalc_user_stats: (username)->
            user = Meteor.users.findOne user_id
            unless user
                user = Meteor.users.findOne username
            user_id = user._id
            # console.log classroom
            user_stats_doc = Docs.findOne
                model:'user_stats'
                user_id: user_id

            unless user_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'user_stats'
                    user_id: user_id
                user_stats_doc = Docs.findOne new_stats_doc_id

            debits = Docs.find({
                model:'classroom_event'
                event_type:'debit'
                user_id:user_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'classroom_event'
                event_type:'credit'
                user_id:user_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            user_balance = total_credit_amount-total_debit_amount

            # average_credit_per_user = total_credit_amount/user_count
            # average_debit_per_user = total_debit_amount/user_count


            Docs.update user_stats_doc._id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    user_balance: user_balance
