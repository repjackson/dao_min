Template.home.onCreated ->
    @autorun => Meteor.subscribe 'me'



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
        if 0 < doc_count < 3 then Tags.find({ count: $lt: doc_count }, {limit:42}) else Tags.find({},{limit:42})
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
                unless val.length is 0
                    selected_tags.push val.toString()
                    $('#tag_search').val ''
                    Meteor.call 'pull_subreddit', val.toString()
            # when 8
            #     if val.length is 0
            #         selected_tags.pop()
    'autocompleteselect #tag_search': (event, template, doc) ->
        selected_tags.push doc.name
        $('#tag_search').val ''



Template.doc_card.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
Template.tag_label.events
    'click .remove_tag': ->
        console.log @
        if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
            Meteor.call 'remove_tag', Template.parentData()._id, @valueOf()

Template.doc_card.events
    'keyup .add_tag': (e,t)->
        if e.which is 13
            new_tag = $('.add_tag').val()
            Meteor.call 'add_tag', @_id, new_tag, ->
                $('.add_tag').val('')

    'click .refresh_post': ->
        # console.log @
        Meteor.call 'get_reddit_post', @_id, @reddit_id

    'click .get_comments': ->
        # console.log @
        Meteor.call 'get_listing_comments', @_id, @reddit_id


Template.doc_card.helpers
    is_image: ->
        image_check = /(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)/
        image_result = image_check.test @url
    is_url: ->
        url_check = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
        url_result = url_check.test @url
    is_youtube: ->
        @domain is 'youtube.com'
        # youtube_check = /("^http:\/\/(?:www\.)?youtube.com\/watch\?(?=[^?]*v=\w+)(?:[^\s?]+)?$")/
        # youtube_result = youtube_check.test @url

Template.home.helpers
    docs: ->
        doc_count = Docs.find().count()
        if Meteor.user() and 'admin' in Meteor.user().roles
            Docs.find {}
        else
            # if doc_count is 1
            Docs.find {},
                limit:1
