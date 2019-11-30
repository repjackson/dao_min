Meteor.users.allow
    insert: (user_id, doc, fields, modifier) -> true
    update: (user_id, doc, fields, modifier) -> true
    remove: (user_id, doc, fields, modifier) ->
        user = Meteor.users.findOne user_id
        if user_id and 'admin' in user.roles
            true
        # if userId and doc._id == userId
        #     true

Docs.allow
    insert: (userId, doc) ->
        userId and doc._author_id is userId
    update: (userId, doc) ->
        true
        # if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles




Meteor.publish 'me', ->
    Meteor.users.find Meteor.userId()


Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'model_docs', (model)->
    Docs.find
        model:model

Meteor.publish 'user_up_concepts', (username)->
    Docs.find
        model:'concept'
        authors: $in: [username]


Meteor.publish 'tags', (
    selected_tags
    selected_authors
    )->
    self = @
    match = {}

    console.log selected_tags

    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # match.authors = $all: selected_authors
    if selected_authors.length > 0 then match.authors = $all: selected_authors
    match.model = 'post'
    # match.answered = $in:[Meteor.userId()]

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: selected_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 42 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    tag_cloud.forEach (tag, i) ->
        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    author_cloud = Docs.aggregate [
        { $match: match }
        { $project: authors: 1 }
        { $unwind: "$authors" }
        { $group: _id: '$authors', count: $sum: 1 }
        { $match: _id: $nin: selected_authors }
        { $sort: count: -1, _id: 1 }
        { $limit: 42 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    author_cloud.forEach (author, i) ->
        self.added 'authors', Random.id(),
            name: author.name
            count: author.count
            index: i


        #
        # doc_match = {}
        # doc_match.author_id = $in: [other_user._id, Meteor.userId()]
        # if selected_overlap_tags.length > 0 then doc_match.tags = $all: selected_overlap_tags
        # doc_match.model = model
        #
        # subHandle = Docs.find(doc_match, {limit:20, sort: timestamp:-1}).observeChanges(
        #     added: (id, fields) ->
        #         # console.log 'added doc', id, fields
        #         # doc_results.push id
        #         self.added 'docs', id, fields
        #     changed: (id, fields) ->
        #         # console.log 'changed doc', id, fields
        #         self.changed 'docs', id, fields
        #     removed: (id) ->
        #         # console.log 'removed doc', id, fields
        #         # doc_results.pull id
        #         self.removed 'docs', id
        # )

        # for doc_result in doc_results

        # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
        #     added: (id, fields) ->
        #         # console.log 'added doc', id, fields
        #         self.added 'docs', id, fields
        #     changed: (id, fields) ->
        #         # console.log 'changed doc', id, fields
        #         self.changed 'docs', id, fields
        #     removed: (id) ->
        #         # console.log 'removed doc', id, fields
        #         self.removed 'docs', id
        # )
        # console.log 'doc handle count', subHandle._observeDriver._results


    self.ready()


Meteor.publish 'facet_docs', (
    selected_tags
    selected_authors
    )->

    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    if selected_authors.length > 0 then match.authors = $all: selected_authors
    # match.authors = $all: selected_authors

    # match.answered = $nin:[Meteor.userId()]

    match.model = 'post'
    Docs.find match,
        sort:_timestamp:1
        limit: 5


Meteor.publish 'users', ->
    Meteor.users.find()


Meteor.methods
    pull_tag: (tag)->
        tag_doc_count =
            Docs.find(tags:$in:[tag]).count()
        console.log 'tag doc count', tag_doc_count
        Docs.update({tags:$in:[tag]}, {$pull:tags:tag}, {multi:true})
