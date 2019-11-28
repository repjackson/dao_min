Router.route '/question/:doc_id/edit', (->
    @layout 'layout'
    @render 'question_edit'
    ), name:'question_edit'
Router.route '/question/:doc_id/view', (->
    @layout 'layout'
    @render 'question_view'
    ), name:'question_view'

@selected_tags = new ReactiveArray []
@selected_upvoter_ids = new ReactiveArray []

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
    # upvote_class: ->
    #     if Meteor.userId() in @upvoter_ids then 'green' else 'outline'
    # downvote_class: ->
    #     if Meteor.userId() in @downvoter_ids then 'red' else 'outline'


Template.nav.onRendered ->
    @autorun => Meteor.subscribe 'me'
Template.nav.events
    'click .add_question': ->
        new_question_id = Docs.insert
            model:'question'
        Router.go "/question/#{new_question_id}/edit"








Template.home.onRendered ->
    @autorun -> Meteor.subscribe('facet_docs', selected_tags.array(), selected_upvoter_ids.array())

Template.question_cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        selected_upvoter_ids.array()
    )
Template.question_cloud.helpers
    all_tags: ->
        question_count = Docs.find(model:'question').count()
        if 0 < question_count < 3 then Tags.find { count: $lt: question_count } else Tags.find({},{limit:42})
    selected_tags: -> selected_tags.array()
    selected_upvoter_ids: -> selected_upvoter_ids.array()
Template.question_cloud.events
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
    'click .calc_stats': -> Meteor.call 'calc_question_stats', Router.current().params.doc_id
Template.remove_button.events
    'click .remove': ->
        if confirm 'delete?'
            Docs.remove @_id





Router.route '/register', (->
    @layout 'layout'
    @render 'register'
    ), name:'register'
Template.register.onCreated ->
    Session.set 'username', null
Template.register.events
    'keyup .username': ->
        username = $('.username').val()
        Session.set 'username', username
        Meteor.call 'find_username', username, (err,res)->
            if res
                Session.set 'enter_mode', 'login'
            else
                Session.set 'enter_mode', 'register'

    'blur .username': ->
        username = $('.username').val()
        Session.set 'username', username
        Meteor.call 'find_username', username, (err,res)->
            if res
                Session.set 'enter_mode', 'login'
            else
                Session.set 'enter_mode', 'register'

    'click .register': (e,t)->
        username = $('.username').val()
        # email = $('.email').val()
        password = $('.password').val()
        # if Session.equals 'enter_mode', 'register'
        # if confirm "register #{username}?"
        options = {
            username:username
            password:password
        }
        Meteor.call 'create_user', options, (err,res)=>
            console.log res
            Meteor.loginWithPassword username, password, (err,res)=>
                if err
                    alert err.reason
                    # if err.error is 403
                    #     Session.set 'message', "#{username} not found"
                    #     Session.set 'enter_mode', 'register'
                    #     Session.set 'username', "#{username}"
                else
                    # Meteor.users.update Meteor.userId(),
                    #     $set:
                    #         first_name: Session.get('first_name')
                    #         last_name: Session.get('last_name')
                    Router.go '/'
        # else
        #     Meteor.loginWithPassword username, password, (err,res)=>
        #         if err
        #             if err.error is 403
        #                 Session.set 'message', "#{username} not found"
        #                 Session.set 'enter_mode', 'register'
        #                 Session.set 'username', "#{username}"
        #         else
        #             Router.go '/'
Template.register.helpers
    can_register: ->
        # Session.get('first_name') and Session.get('last_name') and Session.get('email')
        Session.get('username')

    username: -> Session.get 'username'
    registering: -> Session.equals 'enter_mode', 'register'
    enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''




Template.home.onCreated ->
    # @autorun -> Meteor.subscribe 'model_docs', 'union'
    @autorun -> Meteor.subscribe 'users'
Template.home.events
    'click .add_user': ->
        console.log @
        selected_upvoter_ids.push @_id
Template.home.helpers
    questions: ->
        Docs.find {
            model:'question'
            answer_ids: $nin: [Meteor.userId()]
        }, limit: 1

    users: -> Meteor.users.find()
