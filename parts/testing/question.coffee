if Meteor.isClient
    Router.route '/questions', (->
        @layout 'layout'
        @render 'questions'
        ), name:'questions'
    Router.route '/question/:doc_id/edit', (->
        @layout 'layout'
        @render 'question_edit'
        ), name:'question_edit'
    Router.route '/question/:doc_id/view', (->
        @layout 'layout'
        @render 'question_view'
        ), name:'question_view'



    Template.question_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.question_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'choice'
    Template.question_edit.events
        'click .add_question_item': ->
            new_mi_id = Docs.insert
                model:'question_item'
            Router.go "/question/#{_id}/edit"
    Template.question_edit.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:@_id
        multiple_choice_class: -> if @question_type is 'multiple_choice' then 'active' else ''
        select_essay_class: -> if @question_type is 'essay' then 'active' else ''
        select_number_class: -> if @question_type is 'number' then 'active' else ''
        text_class: -> if @question_type is 'text' then 'active' else ''
        is_multiple_choice_answer: -> @question_type is 'multiple_choice'
        is_essay_answer: -> @question_type is 'essay'
        is_number_answer: -> @question_type is 'number'
        is_text_answer: -> @question_type is 'text'
    Template.question_edit.events
        'click .select_multiple_choice': ->
            Docs.update Router.current().params.doc_id,
                $set: question_type:'multiple_choice'
        'click .select_essay': ->
            Docs.update Router.current().params.doc_id,
                $set: question_type:'essay'
        'click .select_number': ->
            Docs.update Router.current().params.doc_id,
                $set: question_type:'number'
        'click .select_text': ->
            Docs.update Router.current().params.doc_id,
                $set: question_type:'text'
        'click .add_choice': ->
            console.log @
            Docs.insert
                model:'choice'
                question_id:@_id


    Template.question_view.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'bounty'
        @autorun => Meteor.subscribe 'model_docs', 'choice'
        @autorun => Meteor.subscribe 'answer_sessions_from_question_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.question_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.question_view.helpers
        choices: ->
            Docs.find
                model:'choice'
                question_id:@_id
        bounties: ->
            Docs.find
                model:'bounty'
                question_id:@_id
        my_answer: ->
            Docs.findOne
                model:'answer_session'
                question_id: Router.current().params.doc_id
        answer_sessions: ->
            Docs.find
                model:'answer_session'
                question_id: Router.current().params.doc_id
        can_accept: ->
            console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    question_id: Router.current().params.doc_id
            if my_answer_session
                console.log 'false'
                false
            else
                console.log 'true'
                true
        is_multiple_choice_answer: -> @question_type is 'multiple_choice'
        is_essay_answer: -> @question_type is 'essay'
        is_number_answer: -> @question_type is 'number'
        is_text_answer: -> @question_type is 'text'

    Template.question_view.events
        'click .new_answer_session': ->
            # console.log @
            new_answer_session_id = Docs.insert
                model:'answer_session'
                question_id: Router.current().params.doc_id
            Router.go "/answer_session/#{new_answer_session_id}/edit"
        'click .offer_bounty': ->
            console.log @
            new_bounty_id = Docs.insert
                model:'bounty'
                question_id:@_id
            Router.go "/bounty/#{new_bounty_id}/edit"
        'click .accept': ->
            console.log @

        'click .calc_stats': ->
            Meteor.call 'calc_multiple_choice_stats', Router.current().params.doc_id





    Template.questions.onRendered ->
        # @autorun => Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe('question_facet_docs',
            selected_question_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )
    Template.questions.helpers
        questions: ->
            Docs.find
                model:'question'
    Template.questions.events
        'click .add_question': ->
            new_question_id = Docs.insert
                model:'question'
            Router.go "/question/#{new_question_id}/edit"


    Template.question_cloud.onCreated ->
        @autorun -> Meteor.subscribe('question_tags',
            selected_question_tags.array()
            Session.get('selected_target_id')
            )
        # @autorun -> Meteor.subscribe('model_docs', 'target')
    Template.question_cloud.helpers
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: ->
            Docs.findOne Session.get('selected_target_id')
        all_question_tags: ->
            question_count = Docs.find(model:'question').count()
            if 0 < question_count < 3 then Question_tags.find { count: $lt: question_count } else Question_tags.find({},{limit:42})
        selected_question_tags: -> selected_question_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key
    Template.question_cloud.events
        'click .unselect_target': -> Session.set('selected_target_id',null)
        'click .select_target': -> Session.set('selected_target_id',@_id)
        'click .select_question_tag': -> selected_question_tags.push @name
        'click .unselect_question_tag': -> selected_question_tags.remove @valueOf()
        'click #clear_question_tags': -> selected_question_tags.clear()



    Template.question_stats.events
        'click .refresh_question_stats': ->
            Meteor.call 'refresh_question_stats', @_id




if Meteor.isServer
    Meteor.publish 'answer_sessions_from_question_id', (question_id)->
        Docs.find
            model:'answer_session'
            question_id:question_id
    Meteor.publish 'questions', (product_id)->
        Docs.find
            model:'question'
            product_id:product_id
    Meteor.publish 'question_tags', (selected_question_tags, selected_target_id)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd
        self = @
        match = {}

        if selected_target_id
            match.target_id = selected_target_id
        # selected_question_tags.push current_herd

        if selected_question_tags.length > 0 then match.tags = $all: selected_question_tags
        match.model = 'question'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_question_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'question_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'question_facet_docs', (selected_question_tags, selected_target_id)->
        # user = Meteor.users.findOne @userId
        console.log selected_question_tags
        # console.log filter
        self = @
        match = {}
        if selected_target_id
            match.target_id = selected_target_id


        # if filter is 'shop'
        #     match.active = true
        if selected_question_tags.length > 0 then match.tags = $all: selected_question_tags
        match.model = 'question'
        Docs.find match, sort:_timestamp:-1




    Meteor.methods
        refresh_question_stats: (question_id)->
            question = Docs.findOne question_id
            # console.log question
            reservations = Docs.find({model:'reservation', question_id:question_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_question_hours = 0
            average_question_duration = 0

            # shorquestion_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_question_hours += parseFloat(res.hour_duration)

            average_question_cost = total_earnings/reservation_count
            average_question_duration = total_question_hours/reservation_count

            Docs.update question_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_question_hours: total_question_hours.toFixed(0)
                    average_question_cost: average_question_cost.toFixed(0)
                    average_question_duration: average_question_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header question ranking #reservations
            # .ui.small.header question ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg question time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date



        calc_multiple_choice_stats: (question_id)->
            question = Docs.findOne question_id
            answer_count = Docs.find(
                model:'answer_session'
                question_id:question_id
            ).count()
            choice_cursor = Docs.find(
                model:'choice'
                question_id:question_id
            )
            answer_selections_array = []
            for choice in choice_cursor.fetch()
                choice_answer_selections =  Docs.find(
                    model:'answer_session'
                    question_id:question_id
                    choice_selection_id: choice._id
                )
                choice_selection_count = choice_answer_selections.count()
                console.log 'choice selection count', choice_selection_count
                choice_percent = (choice_selection_count/answer_count).toFixed(2)*100
                choice_calc_object = {
                    choice_id:choice._id
                    choice_content:choice.content
                    choice_selection_count:choice_selection_count
                    choice_percent:choice_percent
                }
                answer_selections_array.push choice_calc_object


            Docs.update question._id,
                $set:
                    answer_selections: answer_selections_array
                    answer_count:answer_count
                    choice_count:choice_cursor.count()
