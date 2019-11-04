if Meteor.isClient
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
    Router.route '/post/:doc_id/view', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'

    Template.posts.onCreated ->
        @autorun -> Meteor.subscribe('post_facet_docs',
            selected_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'users_by_role', 'admin'

    Template.posts.helpers
        posts: ->
            Docs.find {
                model:'post'
            }, _timestamp:1


    Template.posts.events
        'click .add_post': ->
            new_post_id =
                Docs.insert
                    model:'post'
            Session.set 'editing', new_post_id

        'click .edit': -> Session.set 'editing_id', @_id
        'click .save': -> Session.set 'editing_id', null





if Meteor.isClient
    Template.post_cloud.onCreated ->
        @autorun -> Meteor.subscribe('post_tags',
            selected_tags.array()
            Session.get('selected_target_id')
            )
        # @autorun -> Meteor.subscribe('model_docs', 'target')

    Template.post_cloud.helpers
        targets: ->
            Meteor.users.find
                admin:true
        selected_target_id: -> Session.get('selected_target_id')
        selected_target: ->
            Docs.findOne Session.get('selected_target_id')
        all_post_tags: ->
            post_count = Docs.find(model:'post').count()
            if 0 < post_count < 3 then Tags.find { count: $lt: post_count } else Tags.find({},{limit:42})
        selected_tags: -> selected_tags.array()
    # Template.sort_item.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set 'sort_key', @key

    Template.post_cloud.events
        'click .unselect_target': -> Session.set('selected_target_id',null)
        'click .select_target': -> Session.set('selected_target_id',@_id)
        'click .select_post_tag': -> selected_tags.push @name
        'click .unselect_post_tag': -> selected_tags.remove @valueOf()
        'click #clear_post_tags': -> selected_tags.clear()

if Meteor.isServer
    Meteor.publish 'post_tags', (selected_tags)->
        self = @
        match = {}

        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.model = $in:['post','reddit']
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        cloud.forEach (tag, i) ->
            self.added 'tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i
        self.ready()


    Meteor.publish 'post_facet_docs', (selected_tags)->
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.model = $in:['post','reddit']
        Docs.find match, sort:_timestamp:-1
