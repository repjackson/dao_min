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
        @autorun -> Meteor.subscribe 'student_stats', Router.current().params.user_id
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        Session.setDefault 'view_side', false

    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: ->
            Meteor.users.findOne Router.current().params.user_id
        user_sections: ->
            Docs.find {
                model:'user_section'
            }, sort:title:1
        student_classrooms: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]

        ssd: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.findOne
                model:'student_stats'
                user_id:user._id
        view_side: -> Session.get 'view_side'
        main_column_class: ->
            if Session.get 'view_side'
                'fourteen wide column'
            else
                'sixteen wide column'
    Template.user_dashboard.helpers
        ssd: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.findOne
                model:'student_stats'
                user_id:user._id

        student_classrooms: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]
        user_events: ->
            Docs.find {
                model:'classroom_event'
            }, sort: _timestamp: -1
        user_credits: ->
            Docs.find {
                model:'classroom_event'
                event_type:'credit'
            }, sort: _timestamp: -1
        user_debits: ->
            Docs.find {
                model:'classroom_event'
                event_type:'debit'
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
        'click .recalc_student_stats': ->
            Meteor.call 'recalc_student_stats', Router.current().params.user_id
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




    Template.teacher_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'classroom'
    Template.teacher_dashboard.helpers
        teacher_classrooms: ->
            user = Meteor.users.findOne Router.current().params.user_id

            Docs.find
                model:'classroom'
                teacher_id: user._id









if Meteor.isServer
    Meteor.publish 'user_events', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'classroom_event'
            user_id:user._id

    Meteor.publish 'student_stats', (username)->
        user = Meteor.users.findOne username:username
        if user
            Docs.find
                model:'student_stats'
                user_id:user._id


    Meteor.methods
        recalc_student_stats: (username)->
            user = Meteor.users.findOne username:username
            unless user
                user = Meteor.users.findOne username
            user_id = user._id
            # console.log classroom
            student_stats_doc = Docs.findOne
                model:'student_stats'
                user_id: user_id

            unless student_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'student_stats'
                    user_id: user_id
                student_stats_doc = Docs.findOne new_stats_doc_id

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

            student_balance = total_credit_amount-total_debit_amount

            # average_credit_per_student = total_credit_amount/student_count
            # average_debit_per_student = total_debit_amount/student_count


            Docs.update student_stats_doc._id,
                $set:
                    credit_count: credit_count
                    debit_count: debit_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    student_balance: student_balance
