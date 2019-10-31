if Meteor.isClient
    Router.route '/schools', ->
        @render 'schools'
    Router.route '/school/:doc_id/', (->
        @layout 'school_view_layout'
        @render 'school_dashboard'
        ), name:'school_view'
    Router.route '/school/:doc_id/dashboard', (->
        @layout 'school_view_layout'
        @render 'school_dashboard'
        ), name:'school_dashboard'
    Router.route '/school/:doc_id/reports', (->
        @layout 'school_view_layout'
        @render 'school_reports'
        ), name:'school_reports'
    Router.route '/school/:doc_id/stats', (->
        @layout 'school_view_layout'
        @render 'school_stats'
        ), name:'school_stats'
    Router.route '/school/:doc_id/debits', (->
        @layout 'school_view_layout'
        @render 'school_debits'
        ), name:'school_debits'
    Router.route '/school/:doc_id/credits', (->
        @layout 'school_view_layout'
        @render 'school_credits'
        ), name:'school_credits'
    Router.route '/school/:doc_id/students', (->
        @layout 'school_view_layout'
        @render 'school_students'
        ), name:'school_students'
    Router.route '/school/:doc_id/feed', (->
        @layout 'school_view_layout'
        @render 'school_feed'
        ), name:'school_feed'
    Router.route '/school/:doc_id/loans', (->
        @layout 'school_view_layout'
        @render 'school_loans'
        ), name:'school_loans'
    Router.route '/school/:doc_id/sponsor', (->
        @layout 'school_view_layout'
        @render 'school_sponsor'
        ), name:'school_sponsor'
    Router.route '/school/:doc_id/shop', (->
        @layout 'school_view_layout'
        @render 'school_shop'
        ), name:'school_shop'
    Router.route '/school/:doc_id/jobs', (->
        @layout 'school_view_layout'
        @render 'school_jobs'
        ), name:'school_jobs'
    Router.route '/school/:doc_id/info', (->
        @layout 'school_view_layout'
        @render 'school_info'
        ), name:'school_info'



if Meteor.isClient
    Template.schools.onRendered ->

        # Session.setDefault 'view_mode', 'cards'
    Template.schools.helpers

        # viewing_cards: -> Session.equals 'view_mode', 'cards'
        # viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.schools.events
        # 'click .set_card_view': ->
        #     Session.set 'view_mode', 'cards'
        # 'click .set_segment_view': ->
        #     Session.set 'view_mode', 'segments'


    Template.school_card.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'school_stats'



    Template.school_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'school_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
    Template.school_dashboard.onRendered ->
        Meteor.setTimeout ->
            $('#date_calendar')
                .calendar({
                    type: 'date'
                })
        , 700
    Template.school_dashboard.helpers
        student_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                school_id: Router.current().params.doc_id

    Template.school_students.onCreated ->
        @autorun => Meteor.subscribe 'school_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        @autorun => Meteor.subscribe 'model_docs', 'school_event'
    Template.school_students.onRendered ->

    Template.school_students.helpers
        school_students: ->
            Meteor.users.find()
        student_credit_types: ->
            Docs.find
                model:'credit_type'
                school_id: Router.current().params.doc_id
        school_debit_types: ->
            Docs.find
                model:'debit_type'
                school_id: Router.current().params.doc_id
    Template.school_students.events



    Template.school_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'school_students', Router.current().params.doc_id
    Template.school_reports.onRendered ->
    Template.school_reports.helpers
        school_students: ->
            Meteor.users.find()
    Template.school_reports.events
        'change .date_select': ->
            console.log $('.date_select').val()







    Template.school_classrooms.onCreated ->
        @autorun => Meteor.subscribe 'school_classrooms', Router.current().params.doc_id
    Template.school_classrooms.onRendered ->
    Template.school_classrooms.helpers
        classrooms: ->
            Docs.find(
                model:'classroom'
            )
    Template.school_classrooms.events









    Template.school_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.school_view_layout.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.school_view_layout.helpers





    Template.school_feed.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'school_event'
    Template.school_feed.helpers
        school_events: ->
            Docs.find {
                model:'school_event'
                school_id:Router.current().params.doc_id
            }, sort: _timestamp:-1
    Template.school_feed.events
        'click .remove': (e,t)->
            if confirm  "undo #{@event_type}?"
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 500
                if @event_type is 'credit'
                    Meteor.users.update @user_id,
                        $inc:credit:-@amount
                else if @event_type is 'debit'
                    Meteor.users.update @user_id,
                        $inc:credit:@amount




    Template.school_selector.onCreated ->
        @school_results = new ReactiveVar
    Template.school_selector.helpers
        school_results: -> Template.instance().school_results.get()
    Template.school_selector.events
        'click .clear_results': (e,t)->
            t.school_results.set null

        'keyup #school_lookup': (e,t)->
            search_value = $(e.currentTarget).closest('#school_lookup').val().trim()
            if search_value.length > 1
                Meteor.call 'lookup_school', search_value, (err,res)=>
                    if err then console.error err
                    else
                        t.school_results.set res

        'click .select_school': (e,t) ->
            classroom = Docs.findOne Router.current().params.doc_id
            Docs.update classroom._id,
                $set:school_id:@_id
            t.school_results.set null
            $('#school_lookup').val ''

        'click .clear_school': ->
            classroom = Docs.findOne Router.current().params.doc_id
            Docs.update classroom._id,
                $unset:school_id:1


    Template.school_card_by_id.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', @data
    Template.school_card_by_id.helpers
        school: -> Docs.findOne Template.currentData()








    Template.school_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'school_stats'
    Template.school_stats.helpers
        csd: ->
            Docs.findOne
                model:'school_stats'
                school_id:Router.current().params.doc_id
    Template.school_stats.events
        'click .refresh_school_stats': ->
            Meteor.call 'refresh_school_stats', @_id




if Meteor.isServer
    Meteor.publish 'school_students', (school_id)->
        school = Docs.findOne school_id
        Meteor.users.find
            username: $in: school.students

    Meteor.publish 'school_classrooms', (school_id)->
        school = Docs.findOne school_id
        Docs.find
            model:'classroom'
            school_id: school_id

    Meteor.publish 'schools', (product_id)->
        Docs.find
            model:'school'
            product_id:product_id


    Meteor.methods
        lookup_school: (title_query)->
            console.log 'searching for school', title_query
            Docs.find({
                title: {$regex:"#{title_query}", $options: 'i'}
                model:'school'
                },{limit:10}).fetch()


        refresh_school_stats: (school_id)->
            school = Docs.findOne school_id
            # console.log school
            school_stats_doc = Docs.findOne
                model:'school_stats'
                school_id: school_id

            unless school_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'school_stats'
                    school_id: school_id
                school_stats_doc = Docs.findOne new_stats_doc_id

            student_count = school.students.length

            debits = Docs.find({
                model:'school_event'
                event_type:'debit'
                school_id:school_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'school_event'
                event_type:'credit'
                school_id:school_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            school_balance = total_credit_amount-total_debit_amount

            average_credit_per_student = total_credit_amount/student_count
            average_debit_per_student = total_debit_amount/student_count


            Docs.update school_stats_doc._id,
                $set:
                    student_count: student_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    debit_count: debit_count
                    credit_count: credit_count
                    school_balance: school_balance
                    average_credit_per_student: average_credit_per_student.toFixed(2)
                    average_debit_per_student: average_debit_per_student.toFixed(2)

            # .ui.small.header total earnings
            # .ui.small.header school ranking #reservations
            # .ui.small.header school ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg school time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
