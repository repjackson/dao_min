Meteor.publish 'tags', (
    selected_tags
    filter
    vote_mode
    )->

    self = @
    match = {}
    # match.tags = $all: selected_tags
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if vote_mode is 'unvoted'
        match.upvoter_ids = $nin: [Meteor.userId()]
        match.downvoter_ids = $nin: [Meteor.userId()]
    else if vote_mode is 'upvoted'
        match.upvoter_ids = $in: [Meteor.userId()]
    else if vote_mode is 'downvoted'
        match.downvoter_ids = $in: [Meteor.userId()]

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

    self.ready()




Meteor.publish 'facet_docs', (
        selected_tags
        filter
        vote_mode
    )->
    self = @
    match = {}
    if vote_mode is 'unvoted'
        match.upvoter_ids = $nin: [Meteor.userId()]
        match.downvoter_ids = $nin: [Meteor.userId()]
    else if vote_mode is 'upvoted'
        match.upvoter_ids = $in: [Meteor.userId()]
    else if vote_mode is 'downvoted'
        match.downvoter_ids = $in: [Meteor.userId()]

    if filter then match.model = filter
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    Docs.find match,
        sort:
            points: -1
            _timestamp:-1
        limit: 5
