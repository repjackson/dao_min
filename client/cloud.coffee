Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        selected_authors.array()
        selected_subreddits.array()
        'reddit'
        )
    @autorun -> Meteor.subscribe('facet_docs',
        selected_tags.array()
        selected_authors.array()
        selected_subreddits.array()
        'reddit'
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
    subreddit_settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Subreddits
                field: 'name'
                matchAll: true
                template: Template.tag_result
            }
        ]
    }
    author_settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Authors
                field: 'name'
                matchAll: true
                template: Template.tag_result
            }
        ]
    }


    all_authors: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Authors.find { count: $lt: doc_count } else Authors.find({},{limit:20})
    selected_authors: -> selected_authors.array()


    all_subreddits: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Subreddits.find { count: $lt: doc_count } else Subreddits.find({},{limit:20})
    selected_subreddits: -> selected_subreddits.array()


Template.cloud.events
    'click .select_author': -> selected_authors.push @name
    'click .unselect_author': -> selected_authors.remove @valueOf()
    'click #clear_authors': -> selected_authors.clear()

    'click .select_subreddit': -> selected_subreddits.push @name
    'click .unselect_subreddit': -> selected_subreddits.remove @valueOf()
    'click #clear_subreddits': -> selected_subreddits.clear()

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



    'keyup #subreddit_search': (e,t)->
        e.preventDefault()
        val = $('#subreddit_search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_subreddits.clear()
                        $('#subreddit_search').val ''
                    else
                        unless val.length is 0
                            selected_subreddits.push val.toString()
                            $('#subreddit_search').val ''
            when 8
                if val.length is 0
                    selected_subreddits.pop()
    'autocompleteselect #subreddit_search': (event, template, doc) ->
        selected_subreddits.push doc.name
        $('#subreddit_search').val ''



    'keyup #author_search': (e,t)->
        e.preventDefault()
        val = $('#author_search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_authors.clear()
                        $('#author_search').val ''
                    else
                        unless val.length is 0
                            selected_authors.push val.toString()
                            $('#author_search').val ''
            when 8
                if val.length is 0
                    selected_authors.pop()
    'autocompleteselect #author_search': (event, template, doc) ->
        selected_authors.push doc.name
        $('#author_search').val ''
