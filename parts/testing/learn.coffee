if Meteor.isClient
    Router.route '/learn', (->
        @layout 'layout'
        @render 'learn'
        ), name:'learn'
    Router.route '/learn/math', (->
        @layout 'layout'
        @render 'learn_math'
        ), name:'learn_math'
    Router.route '/learn/science', (->
        @layout 'layout'
        @render 'learn_science'
        ), name:'learn_science'
    Router.route '/learn/reading', (->
        @layout 'layout'
        @render 'learn_reading'
        ), name:'learn_reading'
    Router.route '/learn/english', (->
        @layout 'layout'
        @render 'learn_english'
        ), name:'learn_english'



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
        select_essay_class: -> if @question_type is 'select_essay' then 'active' else ''
        select_number_class: -> if @question_type is 'select_number' then 'active' else ''
        is_multiple_choice_answer: -> @question_type is 'multiple_choice'
        is_essay_answer: -> @question_type is 'select_essay'
        is_number_answer: -> @question_type is 'select_number'
    Template.question_edit.events
        'click .select_multiple_choice': ->
            Docs.update Router.current().params.doc_id,
                $set: question_type:'multiple_choice'
        'click .select_essay': ->
            Docs.update Router.current().params.doc_id,
                $set: question_type:'select_essay'
        'click .select_number': ->
            Docs.update Router.current().params.doc_id,
                $set: question_type:'select_number'

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
        is_essay_answer: -> @question_type is 'select_essay'
        is_number_answer: -> @question_type is 'select_number'

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





    Template.learn.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'course'
    Template.learn.helpers
        courses: ->
            Docs.find
                model:'course'
        learn: ->
            Docs.find
                model:'question'
    Template.learn.events
        'click .add_course': ->
            new_course_id = Docs.insert
                model:'course'
            Router.go "/course/#{new_course_id}/edit"

    Template.question_stats.events
        'click .refresh_question_stats': ->
            Meteor.call 'refresh_question_stats', @_id
