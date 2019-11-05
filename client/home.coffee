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

    'click .vote_up': ->
        if Meteor.user()
            Meteor.call 'upvote', @
        else
            Router.go "/login"

    'click .vote_down': ->
        if Meteor.user()
            Meteor.call 'downvote', @
        else
            Router.go "/login"

Template.doc_card.helpers
    vote_up_icon_class: ->
        if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else 'outline'
    vote_down_icon_class: ->
        if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else 'outline'
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
    'click .set_upvoted': ->
        if Meteor.user()
            Session.set 'vote_mode', 'upvoted'
        else
            Router.go "/login"
    'click .set_downvoted': ->
        if Meteor.user()
            Session.set 'vote_mode', 'downvoted'
        else
            Router.go "/login"
    'click .set_unvoted': ->
        if Meteor.user()
            Session.set 'vote_mode', 'unvoted'
        else
            Router.go "/login"



Template.home.helpers
    upvoted_class: -> if Session.equals('vote_mode', 'upvoted') then 'active' else 'tertiary'
    downvoted_class: -> if Session.equals('vote_mode', 'downvoted') then 'active' else 'tertiary'
    unvoted_class: -> if Session.equals('vote_mode', 'unvoted') then 'active' else 'tertiary'
    dev_mode: -> Session.get('dev')
    docs: ->
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find {
        }, limit:1
