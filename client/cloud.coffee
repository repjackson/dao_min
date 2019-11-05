Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        'reddit'
        Session.get('vote_mode')
        )
    @autorun -> Meteor.subscribe('facet_docs',
        selected_tags.array()
        'reddit'
        Session.get('vote_mode')
    )

Template.cloud.helpers
    all_tags: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find({},{limit:42})
    cloud_tag_class: ->
        button_class = switch
            when @index <= 5 then 'large'
            when @index <= 12 then ''
            when @index <= 20 then 'small'
        return button_class
    selected_tags: -> selected_tags.array()
    tag_settings: -> {
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

    'keyup #tag_search': (e,t)->
        e.preventDefault()
        val = $('#tag_search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_tags.clear()
                        $('#tag_search').val ''
                    else
                        unless val.length is 0
                            selected_tags.push val.toString()
                            $('#tag_search').val ''
            when 8
                if val.length is 0
                    selected_tags.pop()
    'autocompleteselect #tag_search': (event, template, doc) ->
        selected_tags.push doc.name
        $('#tag_search').val ''
