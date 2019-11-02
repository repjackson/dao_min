if Meteor.isClient
    Template.cloud.onCreated ->
        @autorun -> Meteor.subscribe('tags', selected_tags.array())
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe('facet_docs',selected_tags.array())

    Template.home.helpers
        docs: ->
            doc_count = Docs.find().count()
            if doc_count is 1
                Docs.find {
                }
    Template.cloud.helpers
        all_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find({},{limit:100})
        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'large'
                when @index <= 12 then ''
                when @index <= 20 then 'small'
            return button_class
        selected_tags: -> selected_tags.array()
        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Tags
                    field: 'name'
                    matchAll: true
                    template: Template.tag_result
                }
            ]
        }


    Template.cloud.events
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()

        'keyup #search': (e,t)->
            e.preventDefault()
            val = $('#search').val().toLowerCase().trim()
            switch e.which
                when 13 #enter
                    switch val
                        when 'clear'
                            selected_tags.clear()
                            $('#search').val ''
                        else
                            unless val.length is 0
                                selected_tags.push val.toString()
                                $('#search').val ''
                when 8
                    if val.length is 0
                        selected_tags.pop()

        'autocompleteselect #search': (event, template, doc) ->
            selected_tags.push doc.name
            $('#search').val ''


if Meteor.isServer
    Meteor.publish 'tags', (selected_tags, filter)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}
        # match.tags = $all: selected_tags
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # if filter then match.model = filter
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




    Meteor.publish 'facet_docs', (selected_task_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_task_tags
        # console.log filter
        self = @
        match = {}
        if selected_task_tags.length > 0 then match.tags = $all: selected_task_tags
        Docs.find match,
            sort:_timestamp:-1
            limit: 5
