if Meteor.isClient
    Router.route '/dashboard', (->
        @layout 'admin_layout'
        @render 'dashboard'
        ), name:'dashboard'

    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe('dashboard_facet_docs',
            selected_dashboard_tags.array()
            # Session.get('selected_school_id')
            # Session.get('sort_key')
        )

    Template.dashboard.helpers
        dashboard: ->
            Docs.find {
                model:'dashboard'
            }, _timestamp:1


    Template.dashboard.events
        'click .add_dashboard': ->
            new_dashboard_id =
                Docs.insert
                    model:'dashboard'
            Session.set 'editing', new_dashboard_id

        'click .edit': ->
            Session.set 'editing_id', @_id
        'click .save': ->
            Session.set 'editing_id', null



if Meteor.isServer
    Meteor.publish 'dashboard_tags', (selected_dashboard_tags, selected_target_id)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd
        self = @
        match = {}

        if selected_target_id
            match.target_id = selected_target_id
        # selected_dashboard_tags.push current_herd

        if selected_dashboard_tags.length > 0 then match.tags = $all: selected_dashboard_tags
        match.model = 'dashboard'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_dashboard_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'dashboard_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'dashboard_facet_docs', (selected_dashboard_tags, selected_target_id)->
        # user = Meteor.users.findOne @userId
        console.log selected_dashboard_tags
        # console.log filter
        self = @
        match = {}
        if selected_target_id
            match.target_id = selected_target_id


        # if filter is 'shop'
        #     match.active = true
        if selected_dashboard_tags.length > 0 then match.tags = $all: selected_dashboard_tags
        match.model = 'dashboard'
        Docs.find match, sort:_timestamp:-1
