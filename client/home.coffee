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
    )
Template.questions.helpers
    questions: ->
        Docs.find {
            model:'question'
            answer_ids: $nin: [Meteor.userId()]
        }, limit: 1
Template.nav.events
    'click .add_question': ->
        new_question_id = Docs.insert
            model:'question'
        Router.go "/question/#{new_question_id}/edit"

Template.question_cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
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




Template.user_dashboard.onCreated ->
    @autorun -> Meteor.subscribe 'model_docs', 'union'
Template.user_dashboard.helpers
    up_union_docs: ->
        Docs.find {
            user_ids: $in: [Router.current().params.user_id]
            model:'union'
        }, sort: up_points: -1

    other_user_ids: ->
        # console.log @
        _.without(@user_ids, Router.current().params.user_id)

Template.user_up.onCreated ->
    @autorun -> Meteor.subscribe 'user_up_answers', Router.current().params.user_id
    @autorun -> Meteor.subscribe 'model_docs', 'question'
    @autorun -> Meteor.subscribe 'model_docs', 'union'
Template.user_up.helpers
    up_answers: ->
        Docs.find {
            upvoter_ids:$in:[Meteor.userId()]
        }, sort: _timestamp: -1

    union_doc: ->
        Docs.findOne
            model:'union'
            user_ids:$all:[Meteor.userId(), Router.current().params.user_id]
Template.user_up.events
    'click .calc_up_overlap': ->
        Meteor.call 'calc_user_up_cloud', Meteor.userId()
        Meteor.call 'calc_user_up_cloud', Router.current().params.user_id
        Meteor.call 'calc_up_union', Meteor.userId(), Router.current().params.user_id
