Router.route '/question/:doc_id/edit', (->
    @layout 'layout'
    @render 'question_edit'
    ), name:'question_edit'
Router.route '/question/:doc_id/view', (->
    @layout 'layout'
    @render 'question_view'
    ), name:'question_view'


@selected_tags = new ReactiveArray []
@selected_upvoters = new ReactiveArray []



Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'



Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
Template.registerHelper 'can_edit', () ->
    if Meteor.userId()
        if Meteor.user().roles and 'admin' in Meteor.user().roles
            true
        else if @_author_id is Meteor.userId()
            true

Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'sorted_tags', () -> @tags.sort()
Template.registerHelper 'current_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    user = Meteor.users.findOne Router.current().params.doc_id
    # console.log doc
    # console.log user
    if doc then doc else if user then user


Template.registerHelper 'is_dev', () ->
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles then true else false
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
Template.registerHelper 'author', () -> Meteor.users.findOne @_author_id


Template.registerHelper 'in_dev', -> Meteor.isDevelopment
Template.registerHelper 'in_pro', () -> Meteor.isProduction


Template.voting_full.events
    'click .upvote': (e,t)-> Meteor.call 'upvote', @
    'click .downvote': (e,t)-> Meteor.call 'downvote', @
Template.voting_full.helpers
    upvote_class: ->
        if @upvoters and Meteor.user().username in @upvoters then '' else 'outline grey'
    downvote_class: ->
        if @downvoters and Meteor.user().username in @downvoters then '' else 'outline grey'


Template.nav.onRendered ->
    @autorun => Meteor.subscribe 'me'
Template.nav.events
    'click .add_question': ->
        new_question_id = Docs.insert
            model:'question'
        Router.go "/question/#{new_question_id}/edit"

Template.home.helpers
    docs: ->
        Docs.find
            model:'question'






Template.question_cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        selected_upvoters.array()
    )
Template.question_cloud.helpers
    all_tags: ->
        question_count = Docs.find(model:'question').count()
        if 0 < question_count < 3 then Tags.find { count: $lt: question_count } else Tags.find({},{limit:42})
        # Tags.find {}
    all_upvoters: ->
        question_count = Docs.find(model:'question').count()
        # if 0 < question_count < 3 then Upvoters.find { count: $lt: question_count } else Upvoters.find({},{limit:42})
        Upvoters.find({},{limit:42})
    selected_tags: -> selected_tags.array()
    selected_upvoters: -> selected_upvoters.array()
Template.question_cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()
    'click .select_upvoter': -> selected_upvoters.push @name
    'click .unselect_upvoter': -> selected_upvoters.remove @valueOf()
    'click #clear_upvoters': -> selected_upvoters.clear()

    'keyup #search': (e,t)->
        if e.which is 13
            search_term = t.$('#search').val().trim().toLowerCase()
            selected_tags.push search_term
            t.$('#search').val('')

Template.question_segment.onCreated ->
    # console.log @

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
            Meteor.call 'call_wiki', val
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
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
Template.question_view.onRendered ->
    Meteor.call 'increment_view', Router.current().params.doc_id, ->
Template.question_view.helpers
    'click .calc_stats': -> Meteor.call 'calc_question_stats', Router.current().params.doc_id
Template.remove_button.events
    'click .remove': ->
        if confirm 'delete?'
            Docs.remove @_id






Template.home.onCreated ->
    @autorun -> Meteor.subscribe('facet_docs', selected_tags.array(), selected_upvoters.array())
    @autorun -> Meteor.subscribe('unanswered_questions', Meteor.userId())
    # @autorun -> Meteor.subscribe 'model_docs', 'union'
    # @autorun -> Meteor.subscribe 'users'
Template.home.events
    'click .add_user': ->
        # console.log @
        selected_upvoters.push @_id

Template.home.helpers
    unanswered_questions: ->
        Docs.find {
            model:'question'
            answered: $nin: [Meteor.user().username]
        }, limit: 1
