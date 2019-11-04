if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile_layout'
    Router.route '/user/:username/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:username/connections', (->
        @layout 'profile_layout'
        @render 'user_connections'
        ), name:'user_connections'
    Router.route '/user/:username/karma', (->
        @layout 'profile_layout'
        @render 'user_karma'
        ), name:'user_karma'
    Router.route '/user/:username/payment', (->
        @layout 'profile_layout'
        @render 'user_payment'
        ), name:'user_payment'
    Router.route '/user/:username/finance', (->
        @layout 'profile_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:username/offers', (->
        @layout 'profile_layout'
        @render 'user_offers'
        ), name:'user_offers'
    Router.route '/user/:username/contact', (->
        @layout 'profile_layout'
        @render 'user_contact'
        ), name:'user_contact'
    Router.route '/user/:username/reports', (->
        @layout 'profile_layout'
        @render 'user_reports'
        ), name:'user_reports'
    Router.route '/user/:username/stats', (->
        @layout 'profile_layout'
        @render 'user_stats'
        ), name:'user_stats'
    Router.route '/user/:username/shop', (->
        @layout 'profile_layout'
        @render 'user_shop'
        ), name:'user_shop'
    Router.route '/user/:username/votes', (->
        @layout 'profile_layout'
        @render 'user_votes'
        ), name:'user_votes'
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/jobs', (->
        @layout 'profile_layout'
        @render 'user_jobs'
        ), name:'user_jobs'
    Router.route '/user/:username/stock', (->
        @layout 'profile_layout'
        @render 'user_stock'
        ), name:'user_stock'
    Router.route '/user/:username/requests', (->
        @layout 'profile_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:username/feed', (->
        @layout 'profile_layout'
        @render 'user_feed'
        ), name:'user_feed'
    Router.route '/user/:username/tags', (->
        @layout 'profile_layout'
        @render 'user_tags'
        ), name:'user_tags'
    Router.route '/user/:username/bids', (->
        @layout 'profile_layout'
        @render 'user_bids'
        ), name:'user_bids'
    Router.route '/user/:username/tasks', (->
        @layout 'profile_layout'
        @render 'user_tasks'
        ), name:'user_tasks'
    Router.route '/user/:username/transactions', (->
        @layout 'profile_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/user/:username/gallery', (->
        @layout 'profile_layout'
        @render 'user_gallery'
        ), name:'user_gallery'
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/bookmarks', (->
        @layout 'profile_layout'
        @render 'user_bookmarks'
        ), name:'user_bookmarks'
    Router.route '/user/:username/documents', (->
        @layout 'profile_layout'
        @render 'user_documents'
        ), name:'user_documents'
    Router.route '/user/:username/loans', (->
        @layout 'profile_layout'
        @render 'user_loans'
        ), name:'user_loans'
    Router.route '/user/:username/social', (->
        @layout 'profile_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/user/:username/events', (->
        @layout 'profile_layout'
        @render 'user_events'
        ), name:'user_events'
    Router.route '/user/:username/products', (->
        @layout 'profile_layout'
        @render 'user_products'
        ), name:'user_products'


    Template.profile_layout.onCreated ->
        # @autorun -> Meteor.subscribe 'model_docs', 'classroom'
    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_events', Router.current().params.username
        @autorun -> Meteor.subscribe 'student_stats', Router.current().params.username
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        Session.setDefault 'view_side', false

    Template.profile_layout.helpers
        route_slug: -> "user_#{@slug}"
        user: ->
            Meteor.users.findOne username:Router.current().params.username
        user_sections: ->
            Docs.find {
                model:'user_section'
            }, sort:title:1
        student_classrooms: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]

        ssd: ->
            user = Meteor.users.findOne username:Router.current().params.username
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
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'student_stats'
                user_id:user._id

        student_classrooms: ->
            user = Meteor.users.findOne username:Router.current().params.username
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
            user = Meteor.users.findOne username:Router.current().params.username
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
            Meteor.call 'recalc_student_stats', Router.current().params.username
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
            user = Meteor.users.findOne username:Router.current().params.username

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
