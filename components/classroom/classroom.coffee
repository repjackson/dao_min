if Meteor.isClient
    Router.route '/classrooms', ->
        @render 'classrooms'
    Router.route '/classroom/:doc_id/', (->
        @layout 'classroom_view_layout'
        @render 'classroom_students'
        ), name:'classroom_view'
    Router.route '/classroom/:doc_id/dashboard', (->
        @layout 'classroom_view_layout'
        @render 'classroom_dashboard'
        ), name:'classroom_dashboard'
    Router.route '/classroom/:doc_id/reports', (->
        @layout 'classroom_view_layout'
        @render 'classroom_reports'
        ), name:'classroom_reports'
    Router.route '/classroom/:doc_id/feed', (->
        @layout 'classroom_view_layout'
        @render 'classroom_feed'
        ), name:'classroom_feed'
    Router.route '/classroom/:doc_id/stats', (->
        @layout 'classroom_view_layout'
        @render 'classroom_stats'
        ), name:'classroom_stats'
    Router.route '/classroom/:doc_id/files', (->
        @layout 'classroom_view_layout'
        @render 'classroom_files'
        ), name:'classroom_files'
    Router.route '/classroom/:doc_id/lunch_small', (->
        @layout 'classroom_view_layout'
        @render 'classroom_lunch_small'
        ), name:'classroom_lunch_small'
    Router.route '/classroom/:doc_id/shop', (->
        @layout 'classroom_view_layout'
        @render 'classroom_shop'
        ), name:'classroom_shop'
    Router.route '/classroom/:doc_id/student/:student_id', (->
        @layout 'classroom_view_layout'
        @render 'classroom_student'
        ), name:'classroom_student'
    Router.route '/classroom/:doc_id/students', (->
        @layout 'classroom_view_layout'
        @render 'classroom_students'
        ), name:'classroom_students'
    Router.route '/classroom/:doc_id/lunch', (->
        @layout 'mlayout'
        @render 'classroom_lunch'
        ), name:'classroom_lunch'


    Template.classroom_view_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'school'
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id

    Template.classroom_view_layout.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        # Meteor.setTimeout ->
        #     $('.tabular.menu .item').tab()
        # , 1000

    Template.classroom_view_layout.helpers


    Template.classroom_feed.onCreated ->
        @autorun => Meteor.subscribe 'classroom_docs', 'classroom_event', Router.current().params.doc_id
    Template.classroom_feed.helpers
        classroom_events: ->
            Docs.find {
                model:'classroom_event'
                classroom_id:Router.current().params.doc_id
            }, sort: _timestamp:-1
    Template.classroom_feed.events
        'click .remove_all_events': ->
            if confirm 'remove all events?'
                events = Docs.find({
                    model:'classroom_event'
                    classroom_id:Router.current().params.doc_id
                }).fetch()
                for event in events
                    Docs.remove event._id
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







    Template.classroom_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom_stats'
        Meteor.call 'refresh_classroom_stats', Router.current().params.doc_id

    Template.classroom_stats.helpers
        csd: ->
            Docs.findOne
                model:'classroom_stats'
                classroom_id:Router.current().params.doc_id
    Template.classroom_stats.events
        'click .refresh_classroom_stats': ->
            Meteor.call 'refresh_classroom_stats', @_id



    Template.classroom_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'
    Template.classroom_dashboard.onRendered ->
    Template.classroom_dashboard.helpers
        student_credit_types: ->
            Docs.find
                model:'credit_type'
                # weekly:$ne:true
                classroom_id: Router.current().params.doc_id




    Template.classroom_students.onCreated ->
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'credit_type', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'debit_type', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'classroom_event', Router.current().params.doc_id
    Template.classroom_students.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion(
                selector:
                    trigger: '.title .header'
            )
        , 1000



    Template.classroom_school.helpers
        school_classroom: ->
            Docs.findOne
                model:'school'
                _id: @school_id

    Template.classroom_students.helpers
        # bulk_action_class: ->
        #     console.log @
        weekly_automatic_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'weekly'
        weekly_automatic_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'weekly'
        daily_automatic_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'daily'
        daily_automatic_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'automatic'
                automatic_period:'daily'
        weekly_manual_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'weekly'
        weekly_manual_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'weekly'
        daily_manual_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'daily'
        daily_manual_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                manual_period:'daily'
        daily_manual_classroom_debits: ->
            Docs.find
                model:'debit_type'
                classroom_id: Router.current().params.doc_id
                dispersion_type:'manual'
                scope:'classroom'
                manual_period:'daily'
        daily_manual_classroom_credits: ->
            Docs.find
                model:'credit_type'
                classroom_id: Router.current().params.doc_id
                scope:'classroom'
                dispersion_type:'manual'
                manual_period:'daily'
        classroom_students: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find {
                _id: $in: classroom.student_ids
            }, sort:last_name:-1
        student_credit_types: ->
            Docs.find
                model:'credit_type'
                dispersion_type: 'manual'
                scope: 'student'
                classroom_id: Router.current().params.doc_id
        student_debit_types: ->
            Docs.find
                model:'debit_type'
                dispersion_type: 'manual'
                scope: 'student'
                classroom_id: Router.current().params.doc_id
        classroom_debit_types: ->
            Docs.find
                model:'debit_type'
                scope: 'classroom'
                classroom_id: Router.current().params.doc_id
        student_events: ->
            Docs.find
                model:'classroom_event'
                user_id: @_id

    Template.classroom_students.events
        'click .debit_classroom': ->
            classroom = Docs.findOne Router.current().params.doc_id
            $('.title').transition('shake', 500)
            for student_id in classroom.student_ids
                student = Meteor.users.findOne student_id
                Meteor.users.update student._id,
                    $inc:credit:-@amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: @amount
                    event_type_id: @_id
                    text:"was debited $#{@amount} for #{@title}"
                    user_id: student._id
                    classroom_id: Router.current().params.doc_id
                $('body').toast({
                    message: "#{student.first_name} #{student.last_name} was debited $#{@amount} for #{@title}"
                    class:'error'
                    showProgress: 'bottom'
                })
            # Docs.update Router.current().params.doc_id,
            #     $inc:credit:-@amount
            Docs.insert
                model:'classroom_event'
                event_type:'debit'
                amount: @amount
                event_type_id: @_id
                text:"classroom was debited $#{@amount} for #{@title}"
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "classroom was debited $#{@amount} for #{@title}"
                class:'error'
                showProgress: 'bottom'
            })

        'click .credit_classroom': ->
            classroom = Docs.findOne Router.current().params.doc_id
            $('.title').transition('bounce', 500)
            for student_id in classroom.student_ids
                student = Meteor.users.findOne student_id
                $('body').toast({
                    message: "#{student.first_name} #{student.last_name} was credited $#{@amount} for #{@title}"
                    class:'success'
                    showProgress: 'bottom'
                })
                Meteor.users.update student._id,
                    $inc:credit:@amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'credit'
                    amount: @amount
                    text:"was credited $#{@amount} for #{@title}"
                    user_id: student._id
                    classroom_id: Router.current().params.doc_id
            Docs.insert
                model:'classroom_event'
                event_type:'credit'
                amount: @amount
                event_type_id: @_id
                text:"classroom was credited $#{@amount} for #{@title}"
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "classroom was credited $#{@amount} for #{@title}"
                class:'success'
                showProgress: 'bottom'
            })

        'click .add_bonus': (e,t)->
            # alert 'hi'
            # console.log @
            classroom = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.title').transition('bounce', 500)
            # console.log @
            if Meteor.user()
                amount = if classroom.bonus_amount then classroom.bonus_amount else 1
                $('body').toast({
                    message: "$#{amount} bonus given to #{@first_name} #{@last_name}"
                    class:'success'
                    showProgress: 'bottom'
                })
                Meteor.users.update @_id,
                    $inc:credit:amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'credit'
                    amount: amount
                    text:"was credited #{classroom.bonus_amount}"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id

        'click .add_fine': (e,t)->
            classroom = Docs.findOne Router.current().params.doc_id

            $(e.currentTarget).closest('.title').transition('shake', 500)
            if Meteor.user()
                amount = if classroom.fines_amount then classroom.fines_amount else 1
                $('body').toast({
                    message: "$#{amount} fine given to #{@first_name} #{@last_name}"
                    class:'error'
                    showProgress: 'bottom'
                })
                Meteor.users.update @_id,
                    $inc:credit:-amount
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: amount
                    text:"was fined #{classroom.fines_amount}"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            else
                $('body').toast({
                    message: 'need to be logged in to give fine'
                    class:'error'
                    showProgress: 'bottom'
                })


    Template.classroom_students.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000


    Template.student_credit_button.events
        'click .credit_student': ->
            student = Template.parentData()
            # console.log @
            Meteor.users.update student._id,
                $inc:credit:@amount
            Docs.insert
                model:'classroom_event'
                event_type:'credit'
                amount: @amount
                event_type_id: @_id
                text:"was credited $#{@amount} for #{@title}"
                user_id: student._id
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "#{student.first_name} #{student.last_name} was credited $#{@amount} for #{@title}"
                class:'success'
                showProgress: 'bottom'
            })

    Template.student_debit_button.events
        'click .debit_student': ->
            student = Template.parentData()
            # console.log @
            Meteor.users.update student._id,
                $inc:credit:-@amount
            Docs.insert
                model:'classroom_event'
                event_type:'debit'
                amount: @amount
                event_type_id: @_id
                text:"was debited $#{@amount} for #{@title}"
                user_id: student._id
                classroom_id: Router.current().params.doc_id
            $('body').toast({
                message: "#{student.first_name} #{student.last_name} was debited $#{@amount} for #{@title}"
                class:'error'
                showProgress: 'bottom'
            })




    Template.classroom_reports.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
    Template.classroom_reports.helpers
        classroom_students: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find {
                _id: $in: classroom.student_ids
            }, sort: last_name: 1


    Template.classroom_files.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'file'
    Template.classroom_files.helpers
        classroom_files: ->
            Docs.find
                model:'file'
    # Template.classroom_files.events
    #     'change .date_select': ->
    #         console.log $('.date_select').val()




    Template.classroom_student.onCreated ->
        @autorun => Meteor.subscribe 'user_by_id', Router.current().params.student_id
        @autorun => Meteor.subscribe 'user_events_by_id', Router.current().params.student_id
        @autorun -> Meteor.subscribe 'student_stats_by_id', Router.current().params.student_id
    Template.classroom_student.onRendered ->
        Meteor.call 'recalc_student_stats', Router.current().params.student_id, ->

    Template.classroom_student.helpers
        calculating: ->
            Session.get 'calculating'

        ssd: ->
            user = Meteor.users.findOne Router.current().params.student_id
            Docs.findOne
                model:'student_stats'
                user_id:user._id

        current_student: ->
            Meteor.users.findOne Router.current().params.student_id
        student_debits: ->
            Docs.find
                model:'classroom_event'
                user_id:Router.current().params.student_id

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


    Template.classroom_student.events
        'click .recalc_student_stats': ->
            Session.set 'calculating', true
            Meteor.call 'recalc_student_stats', Router.current().params.student_id, ->
                Session.set 'calculating', false


    Template.credit_event_item.onCreated ->
        @commenting = new ReactiveVar false

    Template.credit_event_item.helpers
        is_commenting: -> Template.instance().commenting.get()

    Template.credit_event_item.events
        'click .note': (e,t)->
            t.commenting.set !t.commenting.get()
            # console.log @

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






if Meteor.isServer
    Meteor.publish 'classroom_students', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            _id: $in: classroom.student_ids

    Meteor.publish 'user_events_by_id', (student_id)->
        # classroom = Docs.findOne classroom_id
        # Meteor.users.find
        #     _id: $in: classroom.student_ids
        Docs.find
            model:'classroom_event'
            user_id:student_id


    Meteor.publish 'student_stats_by_id', (student_id)->
        # classroom = Docs.findOne classroom_id
        # Meteor.users.find
        #     _id: $in: classroom.student_ids
        Docs.find
            model:'student_stats'
            user_id:student_id


    Meteor.publish 'classroom_docs', (model, classroom_id)->
        Docs.find
            model:model
            classroom_id:classroom_id


    Meteor.methods
        refresh_classroom_stats: (classroom_id)->
            classroom = Docs.findOne classroom_id
            # console.log classroom
            classroom_stats_doc = Docs.findOne
                model:'classroom_stats'
                classroom_id: classroom_id

            unless classroom_stats_doc
                new_stats_doc_id = Docs.insert
                    model:'classroom_stats'
                    classroom_id: classroom_id
                classroom_stats_doc = Docs.findOne new_stats_doc_id

            student_count = classroom.student_ids.length

            debits = Docs.find({
                model:'classroom_event'
                event_type:'debit'
                classroom_id:classroom_id})
            debit_count = debits.count()
            total_debit_amount = 0
            for debit in debits.fetch()
                total_debit_amount += debit.amount

            credits = Docs.find({
                model:'classroom_event'
                event_type:'credit'
                classroom_id:classroom_id})
            credit_count = credits.count()
            total_credit_amount = 0
            for credit in credits.fetch()
                total_credit_amount += credit.amount

            classroom_balance = total_credit_amount-total_debit_amount

            average_credit_per_student = total_credit_amount/student_count
            average_debit_per_student = total_debit_amount/student_count


            Docs.update classroom_stats_doc._id,
                $set:
                    student_count: student_count
                    total_credit_amount: total_credit_amount
                    total_debit_amount: total_debit_amount
                    debit_count: debit_count
                    credit_count: credit_count
                    classroom_balance: classroom_balance
                    average_credit_per_student: average_credit_per_student.toFixed(2)
                    average_debit_per_student: average_debit_per_student.toFixed(2)

            # .ui.small.header total earnings
            # .ui.small.header classroom ranking #reservations
            # .ui.small.header classroom ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg classroom time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
