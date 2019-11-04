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




SyncedCron.add({
        name: 'random sub'
        schedule: (parser) ->
            parser.text 'every 10 minutes'
        job: ->
            Meteor.call 'pull_subreddit', 'wikipedia', (err, res)->
    }
)


if Meteor.isProduction
    SyncedCron.start()

Meteor.publish 'tags', (
    selected_theme_tags
    selected_usernames=[]
    selected_subreddits
    )->

    self = @
    match = {}
    # match.tags = $all: selected_theme_tags
    if selected_theme_tags.length > 0 then match.tags = $all: selected_theme_tags
    # if selected_usernames.length > 0 then match.subreddit = $all: selected_usernames
    if selected_subreddits.length > 0 then match.subreddit = $all: selected_subreddits



    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_theme_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    subreddit_cloud = Docs.aggregate [
        { $match: match }
        { $project: subreddit: 1 }
        { $unwind: "$subreddit" }
        { $group: _id: '$subreddit', count: $sum: 1 }
        { $match: _id: $nin: selected_subreddits }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    subreddit_cloud.forEach (subreddit, i) ->
        self.added 'subreddits', Random.id(),
            name: subreddit.name
            count: subreddit.count
            index: i

    # username_cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: subreddit: 1 }
    #     { $unwind: "$subreddit" }
    #     { $group: _id: '$subreddit', count: $sum: 1 }
    #     { $match: _id: $nin: selected_theme_tags }
    #     { $sort: count: -1, _id: 1 }
    #     { $limit: 42 }
    #     { $project: _id: 0, name: '$_id', count: 1 }
    #     ]
    # username_cloud.forEach (username, i) ->
    #     self.added 'usernames', Random.id(),
    #         name: username.name
    #         count: username.count
    #         index: i
    #
    self.ready()




Meteor.publish 'facet_docs', (
        selected_theme_tags
        selected_usernames=[]
        selected_subreddits
    )->
    self = @
    match = {}
    if selected_theme_tags.length > 0 then match.tags = $all: selected_theme_tags
    # if selected_usernames.length > 0 then match.subreddit = $all: selected_usernames
    if selected_subreddits.length > 0 then match.subreddit = $all: selected_subreddits
    Docs.find match,
        sort:_timestamp:-1
        limit: 5


Meteor.methods
    pull_tag: (tag)->
        tag_doc_count =
            Docs.find(tags:$in:[tag]).count()
        console.log 'tag doc count', tag_doc_count
        Docs.update({tags:$in:[tag]}, {$pull:tags:tag}, {multi:true})

    import_site: (site)->
        existing_doc = Docs.findOne url:site
        if existing_doc
            console.log 'found existing doc', existing_doc
        else
            new_doc_id = Docs.insert
                url: site
            Meteor.call 'call_watson', new_doc_id, 'url', 'url'

    delete_docs_tag: (tag)->
        tag_doc_count =
            Docs.find(tags:$in:[tag]).count()
        console.log 'tag doc count', tag_doc_count
        Docs.remove({tags:$in:[tag]})
