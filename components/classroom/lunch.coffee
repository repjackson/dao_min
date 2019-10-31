if Meteor.isClient
    Template.classroom_lunch.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'classroom_event', Router.current().params.doc_id
    Template.classroom_lunch_small.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_students', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'classroom_docs', 'classroom_event', Router.current().params.doc_id

    Template.classroom_lunch.events
        'click .back_to_classroom': ->
            Router.go "/classroom/#{Router.current().params.doc_id}/lunch_small"
        'click .choose_home': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: -3
                    debit_type: 'lunch'
                    date:moment().format("MM-DD-YYYY")
                    text:"was debited 3 for a home lunch"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            , 1000

        'click .choose_cafeteria': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: -5
                    date:moment().format("MM-DD-YYYY")
                    debit_type: 'lunch'
                    text:"was debited 5 for a cafeteria lunch"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            , 1000

    Template.classroom_lunch.helpers
        classroom_students: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: classroom.student_ids

        lunch_chosen: ->
            today = moment().format("MM-DD-YYYY")
            chosen_lunch = Docs.findOne
                debit_type:'lunch'
                date:today
                user_id: @_id
            # console.log chosen_lunch
            chosen_lunch
        classroom_debit_types: ->
            Docs.find
                model:'debit_type'
                # weekly:$ne:true
                classroom_id: Router.current().params.doc_id



    Template.classroom_lunch_small.events
        'click .choose_home': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: -3
                    debit_type: 'lunch'
                    date:moment().format("MM-DD-YYYY")
                    text:"was debited 3 for a home lunch"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            , 1000

        'click .choose_cafeteria': (e,t)->
            $(e.currentTarget).closest('.button').transition('zoom', 1000)
            $(e.currentTarget).closest('.card').transition('fade left', 1000)
            Meteor.setTimeout =>
                Docs.insert
                    model:'classroom_event'
                    event_type:'debit'
                    amount: -5
                    date:moment().format("MM-DD-YYYY")
                    debit_type: 'lunch'
                    text:"was debited 5 for a cafeteria lunch"
                    user_id: @_id
                    classroom_id: Router.current().params.doc_id
            , 1000

    Template.classroom_lunch_small.helpers
        classroom_students: ->
            classroom = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id: $in: classroom.student_ids

        lunch_chosen: ->
            today = moment().format("MM-DD-YYYY")
            chosen_lunch = Docs.findOne
                debit_type:'lunch'
                date:today
                user_id: @_id
            # console.log chosen_lunch
            chosen_lunch
        classroom_debit_types: ->
            Docs.find
                model:'debit_type'
                # weekly:$ne:true
                classroom_id: Router.current().params.doc_id
