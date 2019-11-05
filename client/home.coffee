Template.doc_card.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000
Template.tag_label.events
    'click .remove_tag': ->
        console.log @
        if Meteor.isDevelopment
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
Template.home.events

Template.home.helpers
    dev_mode: -> Session.get('dev')
    docs: ->
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find {
        }, limit:1
