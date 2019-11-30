Router.route '/concept/:doc_id/edit', (->
    @layout 'layout'
    @render 'concept_edit'
    ), name:'concept_edit'
Router.route '/concept/:doc_id/view', (->
    @layout 'layout'
    @render 'concept_view'
    ), name:'concept_view'


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


Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
    @autorun => Meteor.subscribe 'model_docs', 'response'
Template.nav.events
    'click .add_concept': ->
        new_concept_id = Docs.insert
            model:'concept'
        Router.go "/concept/#{new_concept_id}/edit"

Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', 'response'

Template.home.helpers
    docs: ->
        Docs.find
            model:'concept'





Template.concept_cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        selected_upvoters.array()
    )
Template.concept_cloud.helpers
    all_tags: ->
        concept_count = Docs.find(model:'concept').count()
        if 0 < concept_count < 3 then Tags.find { count: $lt: concept_count } else Tags.find({},{limit:42})
        # Tags.find {}
    all_upvoters: ->
        concept_count = Docs.find(model:'concept').count()
        # if 0 < concept_count < 3 then Upvoters.find { count: $lt: concept_count } else Upvoters.find({},{limit:42})
        Upvoters.find({},{limit:42})
    selected_tags: -> selected_tags.array()
    selected_upvoters: -> selected_upvoters.array()
Template.concept_cloud.events
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

Template.concept_segment.onCreated ->
    # console.log @
Template.concept_edit.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
Template.concept_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'concept_docs', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'dep'
Template.concept_edit.events
    'blur .edit_title': (e,t)->
        val = t.$('.edit_title').val().trim().toLowerCase()
        Docs.update Router.current().params.doc_id,
            $set:title:val
    'keyup .edit_title': (e,t)->
        if e.which is 13
            val = t.$('.edit_title').val().trim().toLowerCase()
            Docs.update Router.current().params.doc_id,
                $set:title:val


Template.response_edit.helpers
    my_response: ->
        Docs.findOne
            root:@title
            model:'response'
            _author_id: Meteor.userId()

Template.response_edit.events
    'click .add_response': ->
        console.log @
        Docs.insert
            model:'response'
            root:@title
            parent_id: @_id

    'keyup .new_tag': (e,t)->
        if e.which is 13
            tag_val = t.$('.new_tag').val().trim().toLowerCase()
            Docs.update @_id,
                $addToSet:tags:tag_val
            concept = Template.currentData()
            t.$('.new_tag').val('')
            # console.log Template.parentData()
            Meteor.call 'calc_parent_tags', Template.currentData()._id

Template.tag_button.events
    'click .remove_tag': (e,t)->
        response = Template.parentData()
        console.log 'response', response
        console.log 'this', @
        # response = Template.currentData()
        concept = Template.parentData(2)
        console.log 'concept', concept
        tag = Template.currentData()
        console.log 'tag', tag

        Docs.update response._id,
            $pull: tags: tag
        # Docs.update concept._id,
        #     $pull: tags: tag
        # t.$('.new_tag').focus()
        t.$('.new_tag').val(tag)
        Meteor.call 'calc_parent_tags', concept._id



Template.response_edit.events

Template.concept_edit.helpers
    my_response: ->
        console.log @
        Docs.findOne
            root:@title
            model:'response'
            _author_id: Meteor.userId()




Template.concept_view.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'concept_responses', Router.current().params.doc_id

Template.concept_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


Template.concept_view.onRendered ->

Template.concept_view.helpers
    responses: ->
        Docs.find
            model:'response'
            parent_id: Router.current().params.doc_id


Template.remove_button.events
    'click .remove_doc': ->
        if confirm 'delete?'
            Docs.remove @_id






Template.home.onCreated ->
    @autorun -> Meteor.subscribe('facet_docs', selected_tags.array(), selected_upvoters.array())
    @autorun -> Meteor.subscribe('unanswered_concepts', Meteor.userId())
    # @autorun -> Meteor.subscribe 'model_docs', 'union'
    # @autorun -> Meteor.subscribe 'users'
Template.home.events
    'click .add_user': ->
        # console.log @
        selected_upvoters.push @_id

Template.home.helpers
    unanswered_concepts: ->
        Docs.find {
            model:'concept'
            answered: $nin: [Meteor.user().username]
        }, limit: 1
