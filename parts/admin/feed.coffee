if Meteor.isClient
    Router.route '/feed', (->
        @layout 'admin_layout'
        @render 'feed'
        ), name:'feed'

    Template.feed.onCreated ->
        @autorun -> Meteor.subscribe 'event_log'

    Template.feed.helpers
        feed: ->
            Docs.find {
                model:'event'
            }, _timestamp:1


    Template.feed.events
        'click .add_event': ->
            new_event_id =
                Docs.insert
                    model:'event'
            Session.set 'editing', new_event_id

        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null



if Meteor.isServer
    Meteor.publish 'event_tags', (selected_event_tags, selected_target_id)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd
        self = @
        match = {}

        if selected_target_id
            match.target_id = selected_target_id
        # selected_event_tags.push current_herd

        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.model = 'event'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_event_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'event_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'event_facet_docs', (selected_event_tags, selected_target_id)->
        # user = Meteor.users.findOne @userId
        console.log selected_event_tags
        # console.log filter
        self = @
        match = {}
        if selected_target_id
            match.target_id = selected_target_id


        # if filter is 'shop'
        #     match.active = true
        if selected_event_tags.length > 0 then match.tags = $all: selected_event_tags
        match.model = 'event'
        Docs.find match, sort:_timestamp:-1
