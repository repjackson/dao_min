Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags',
        selected_tags.array()
        selected_usernames.array()
        selected_subreddits.array()
        'reddit'
        )
    @autorun -> Meteor.subscribe('facet_docs',
        selected_tags.array()
        selected_usernames.array()
        selected_subreddits.array()
        'reddit'
    )

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


    all_usernames: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Usernames.find { count: $lt: doc_count } else Usernames.find({},{limit:20})
    selected_usernames: -> selected_usernames.array()


    all_subreddits: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Subreddits.find { count: $lt: doc_count } else Subreddits.find({},{limit:20})
    selected_subreddits: -> selected_subreddits.array()


Template.cloud.events
    'click .select_username': -> selected_usernames.push @name
    'click .unselect_username': -> selected_usernames.remove @valueOf()
    'click #clear_usernames': -> selected_usernames.clear()

    'click .select_subreddit': -> selected_subreddits.push @name
    'click .unselect_subreddit': -> selected_subreddits.remove @valueOf()
    'click #clear_subreddits': -> selected_subreddits.clear()

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



Template.doc_card.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
Template.doc_card.events
    'click .refresh_post': ->
        # console.log @
        Meteor.call 'get_reddit_post', @_id, @reddit_id
Template.doc_card.helpers
    is_image: ->
        image_check = /(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)/
        image_result = image_check.test @url

    is_url: ->
        url_check = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
        url_result = url_check.test @url

    is_youtube: ->
        @subreddit is 'youtube.com'
        # youtube_check = /("^http:\/\/(?:www\.)?youtube.com\/watch\?(?=[^?]*v=\w+)(?:[^\s?]+)?$")/
        # youtube_result = youtube_check.test @url
