Meteor.publish 'tags', (
    selected_tags
    selected_authors=[]
    selected_subreddits
    filter
    )->

    self = @
    match = {}
    # match.tags = $all: selected_tags
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if selected_authors.length > 0 then match.subreddit = $all: selected_authors
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

    author_cloud = Docs.aggregate [
        { $match: match }
        { $project: author: 1 }
        { $unwind: "$author" }
        { $group: _id: '$author', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 42 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    author_cloud.forEach (author, i) ->
        self.added 'authors', Random.id(),
            name: author.name
            count: author.count
            index: i

    self.ready()




Meteor.publish 'facet_docs', (
        selected_tags
        selected_authors=[]
        selected_subreddits
        filter
    )->
    self = @
    match = {}
    if filter then match.model = filter
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if selected_authors.length > 0 then match.author = $all: selected_authors
    if selected_subreddits.length > 0 then match.subreddit = $all: selected_subreddits
    Docs.find match,
        sort:_timestamp:-1
        limit: 5
