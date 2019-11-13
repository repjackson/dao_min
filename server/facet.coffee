Meteor.publish 'tags', (
    selected_tags
    )->

    self = @
    match = {}
    # match.tags = $all: selected_tags
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
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
    )->
    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    count = Docs.find(match).count()
    console.log 'count', count
    Docs.find match,
        sort:
            _timestamp:-1
            ups: -1
        limit: 10
