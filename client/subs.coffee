Template.subs.onCreated ->
    @autorun => Meteor.subscribe 'subreddits'

Template.subs.helpers
    subreddits: ->
        Subreddits.find({},{sort:title:1})
Template.subs.events
    'click .remove': (e,t)->
        if confirm "remove #{@title}?"
            Subreddits.remove @_id
    'keyup .add_subreddit': (e,t)->
        e.preventDefault()
        val = $('.add_subreddit').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                unless val.length is 0
                    existing_sub = Subreddits.findOne
                        title:val
                    unless existing_sub
                        Subreddits.insert
                            title: val
                        Meteor.call 'pull_subreddit', val
                    else
                        console.log 'skipping existing sub', val
                    $('.add_subreddit').val ''
