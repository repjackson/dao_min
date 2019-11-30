Router.route '/post/:doc_id/edit', (->
    @layout 'layout'
    @render 'post_edit'
    ), name:'post_edit'
Router.route '/post/:doc_id/view', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view'


@selected_tags = new ReactiveArray []
@selected_authors = new ReactiveArray []



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
        if @authors and Meteor.user().username in @authors then '' else 'outline grey'
    downvote_class: ->
        if @downvoters and Meteor.user().username in @downvoters then '' else 'outline grey'


Template.nav.onCreated ->
    @autorun => Meteor.subscribe 'me'
Template.nav.events
    'click .add_post': ->
        new_post_id = Docs.insert
            model:'post'
        Router.go "/post/#{new_post_id}/edit"


Template.home.helpers
    docs: ->
        Docs.find
            model:'post'





Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        selected_authors.array()
    )
Template.cloud.helpers
    all_tags: ->
        post_count = Docs.find(model:'post').count()
        if 0 < post_count < 3 then Tags.find { count: $lt: post_count } else Tags.find({},{limit:42})
        # Tags.find {}
    all_authors: ->
        post_count = Docs.find(model:'post').count()
        # if 0 < post_count < 3 then Authors.find { count: $lt: post_count } else Upvoters.find({},{limit:42})
        Authors.find({},{limit:42})
    selected_tags: -> selected_tags.array()
    selected_authors: -> selected_authors.array()
Template.cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()
    'click .select_author': -> selected_authors.push @name
    'click .unselect_author': -> selected_authors.remove @valueOf()
    'click #clear_authors': -> selected_authors.clear()

    'keyup #search': (e,t)->
        if e.which is 13
            search_term = t.$('#search').val().trim().toLowerCase()
            selected_tags.push search_term
            t.$('#search').val('')

Template.post_segment.onCreated ->
    # console.log @
Template.post_edit.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'dep'
Template.post_edit.events
    'blur .edit_title': (e,t)->
        val = t.$('.edit_title').val().trim().toLowerCase()
        Docs.update Router.current().params.doc_id,
            $set:title:val
    'keyup .edit_title': (e,t)->
        if e.which is 13
            val = t.$('.edit_title').val().trim().toLowerCase()
            Docs.update Router.current().params.doc_id,
                $set:title:val

Template.post_edit.events
    'keyup .new_tag': (e,t)->
        if e.which is 13
            tag_val = t.$('.new_tag').val().trim().toLowerCase()
            Docs.update @_id,
                $addToSet:tags:tag_val
            post = Template.currentData()
            t.$('.new_tag').val('')
            # console.log Template.parentData()

Template.tag_button.events
    'click .remove_tag': (e,t)->
        post = Template.parentData()
        console.log 'post', post
        console.log 'this', @
        # post = Template.currentData()
        post = Template.parentData(2)
        console.log 'post', post
        tag = Template.currentData()
        console.log 'tag', tag

        Docs.update post._id,
            $pull: tags: tag
        # Docs.update post._id,
        #     $pull: tags: tag
        # t.$('.new_tag').focus()
        t.$('.new_tag').val(tag)




Template.post_view.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


Template.post_view.onRendered ->



Template.remove_button.events
    'click .remove_doc': ->
        if confirm 'delete?'
            Docs.remove @_id






Template.home.onCreated ->
    @autorun -> Meteor.subscribe('facet_docs', selected_tags.array(), selected_authors.array())
Template.home.events
    'click .add_user': ->
        # console.log @
        selected_authors.push @_id

Template.home.helpers
    # unanswered_posts: ->
    #     Docs.find {
    #         model:'post'
    #         answered: $nin: [Meteor.user().username]
    #     }, limit: 1
