Meteor.users.allow
    insert: (user_id, doc, fields, modifier) ->
        # user_id
        true
        # if user_id and doc._id == user_id
        #     true
    update: (user_id, doc, fields, modifier) ->
        true
        # if user_id and doc._id == user_id
        #     true
    remove: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'admin' in user.roles
            true
        # if userId and doc._id == userId
        #     true


Docs.allow
    insert: (userId, doc) ->
        if doc.model is 'bug'
            true
        else
            userId and doc._author_id is userId
    update: (userId, doc) ->
        if doc.model in ['test']
            true
        else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
            true
        else
            doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles


SyncedCron.add({
    name: 'random sub'
    schedule: (parser) ->
        parser.text 'every 2 hours'
    job: ->
        Meteor.call 'pull_subreddit', 'recipes', (err, res)->
    }
)
SyncedCron.add({
    name: 'random sub'
    schedule: (parser) ->
        parser.text 'every 1 hours'
    job: ->
        Meteor.call 'pull_subreddit', 'Whatsinmycupboard', (err, res)->
    }
)
# SyncedCron.add({
#     name: 'random sub'
#     schedule: (parser) ->
#         parser.text 'every 120 minutes'
#     job: ->
#         Meteor.call 'pull_subreddit', 'usnews', (err, res)->
#         Meteor.call 'pull_subreddit', 'worldnews', (err, res)->
#         Meteor.call 'pull_subreddit', 'news', (err, res)->
#         Meteor.call 'pull_subreddit', 'business', (err, res)->
#         Meteor.call 'pull_subreddit', 'finance', (err, res)->
#         Meteor.call 'pull_subreddit', 'investing', (err, res)->
#         Meteor.call 'pull_subreddit', 'businessnews', (err, res)->
#         Meteor.call 'pull_subreddit', 'cooking', (err, res)->
#         Meteor.call 'pull_subreddit', 'food', (err, res)->
#     }
# )


if Meteor.isProduction
    SyncedCron.start()
