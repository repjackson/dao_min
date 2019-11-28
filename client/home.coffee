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


Template.nav.onRendered ->
    @autorun => Meteor.subscribe 'me'
Template.questions.onRendered ->
    @autorun -> Meteor.subscribe('facet_docs',
        selected_tags.array()
        Session.get('view_answered')
        Session.get('view_unanswered')
        Session.get('view_up')
        Session.get('view_down')
    )
Template.questions.helpers
    questions: ->
        Docs.find {
            model:'question'
            answer_ids: $nin: [Meteor.userId()]
        }, limit: 1
    # view_answered_class: -> if Session.equals('view_answered',true) then 'active' else ''
    # view_unanswered_class: -> if Session.equals('view_unanswered',true) then 'active' else ''
    # view_up_class: -> if Session.equals('view_up',true) then 'active' else ''
    # view_down_class: -> if Session.equals('view_down',true) then 'active' else ''
Template.nav.events
    'click .add_question': ->
        new_question_id = Docs.insert
            model:'question'
        Router.go "/question/#{new_question_id}/edit"
Template.questions.events
    'click .view_answered': ->
        if Session.equals('view_answered',true)
            Session.set('view_answered', false)
        else
            Session.set('view_answered', true)
            Session.set('view_unanswered', false)
    'click .view_unanswered': ->
        if Session.equals('view_unanswered',true)
            Session.set('view_unanswered', false)
        else
            Session.set('view_unanswered', true)
            Session.set('view_answered', false)
    'click .view_up': ->
        if Session.equals 'view_up',true
            Session.set('view_up', false)
        else
            Session.set('view_answered', true)
            Session.set('view_unanswered', false)
            Session.set('view_up', true)
    'click .view_down': ->
        if Session.equals 'view_down',true
            Session.set('view_down', false)
        else
            Session.set('view_answered', true)
            Session.set('view_unanswered', false)
            Session.set('view_down', true)

Template.question_cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        Session.get('view_answered')
        Session.get('view_unanswered')
        Session.get('view_up')
        Session.get('view_down')
    )

    # @autorun -> Meteor.subscribe('model_docs', 'target')
Template.question_cloud.helpers
    selected_target_id: -> Session.get('selected_target_id')
    selected_target: ->
        Docs.findOne Session.get('selected_target_id')
    all_tags: ->
        question_count = Docs.find(model:'question').count()
        if 0 < question_count < 3 then Tags.find { count: $lt: question_count } else Tags.find({},{limit:42})
    selected_tags: -> selected_tags.array()
# Template.sort_item.events
#     'click .set_sort': ->
#         console.log @
#         Session.set 'sort_key', @key
Template.question_cloud.events
    'click .unselect_target': -> Session.set('selected_target_id',null)
    'click .select_target': -> Session.set('selected_target_id',@_id)
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()


Template.question_segment.onCreated ->
    # console.log @
    # @autorun => Meteor.subscribe('answer_sessions_from_question_id', @data._id)
    # @autorun => Meteor.subscribe('my_answer_from_question_id', @data._id)

Template.question_segment.events

Template.question_segment.helpers



Template.question_edit.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
Template.question_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'question_docs', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'dep'
Template.question_edit.events
    'blur .edit_title': (e,t)->
        val = t.$('.edit_title').val().trim().toLowerCase()
        Docs.update Router.current().params.doc_id,
            $set:title:val
    'keyup .edit_title': (e,t)->
        if e.which is 13
            val = t.$('.edit_title').val().trim().toLowerCase()
            Docs.update Router.current().params.doc_id,
                $set:title:val
            Meteor.call 'search_reddit', val


    'keyup .new_tag': (e,t)->
        if e.which is 13
            tag_val = t.$('.new_tag').val().trim().toLowerCase()
            Docs.update Router.current().params.doc_id,
                $addToSet:"tags":tag_val
            t.$('.new_tag').val('')

    'click .remove_element': (e,t)->
        element = @valueOf()
        doc = Docs.findOne parent._id
        Docs.update Router.current().params.doc_id,
            $pull:tags:element

        t.$('.new_tag').focus()
        t.$('.new_tag').val(element)

Template.question_edit.helpers








Template.question_view.onCreated ->
    @autorun => Meteor.subscribe 'answer_sessions_from_question_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
Template.question_view.onRendered ->
    Meteor.call 'increment_view', Router.current().params.doc_id, ->
Template.question_view.helpers
    'click .calc_stats': ->
        Meteor.call 'calc_question_stats', Router.current().params.doc_id


Template.remove_button.events
    'click .remove': ->
        if confirm 'delete?'
            Docs.remove @_id
