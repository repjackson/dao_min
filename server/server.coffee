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

Meteor.publish 'tags', (selected_tags, filter)->
    # user = Meteor.users.finPdOne @userId
    # current_herd = user.profile.current_herd

    self = @
    match = {}
    # match.tags = $all: selected_tags
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # if filter then match.model = filter
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




Meteor.publish 'facet_docs', (selected_task_tags)->
    # user = Meteor.users.findOne @userId
    console.log selected_task_tags
    # console.log filter
    self = @
    match = {}
    if selected_task_tags.length > 0 then match.tags = $all: selected_task_tags
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
