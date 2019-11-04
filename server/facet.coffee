Meteor.publish 'tags', (
    selected_tags
    selected_usernames=[]
    selected_subreddits
    filter
    )->

    self = @
    match = {}
    # match.tags = $all: selected_tags
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # if selected_usernames.length > 0 then match.subreddit = $all: selected_usernames
    if selected_subreddits.length > 0 then match.subreddit = $all: selected_subreddits

    if filter then match.model = filter

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 42 }
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
    #     { $match: _id: $nin: selected_tags }
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
        selected_tags
        selected_usernames=[]
        selected_subreddits
        filter
    )->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # if selected_usernames.length > 0 then match.subreddit = $all: selected_usernames
    if filter then match.model = filter

    if selected_subreddits.length > 0 then match.subreddit = $all: selected_subreddits
    Docs.find match,
        sort:_timestamp:-1
        limit: 5
