Meteor.publish 'me', ->
    Meteor.users.find Meteor.userId()

Meteor.publish 'unanswered_questions', (user_id)->
    Docs.find
        model:'question'
        answer_ids: $nin: [user_id]
Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'model_docs', (model)->
    Docs.find
        model:model

Meteor.publish 'user_up_questions', (user_id)->
    Docs.find
        model:'question'
        upvoter_ids: $in: [user_id]


Meteor.publish 'user_stats', (user_id)->
    user = Meteor.users.findOne user_id
    if user
        Docs.find
            model:'user_stats'
            user_id:user._id


Meteor.publish 'tags', (
    selected_tags
    selected_upvoter_ids
    )->
    self = @
    match = {}

    console.log selected_tags
    # if view_answered
    #     match.answer_ids = $in:[Meteor.userId()]
    # if view_unanswered
    #     match.answer_ids = $nin:[Meteor.userId()]

    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.upvoter_ids = $all: selected_upvoter_ids
    # if selected_upvoter_ids.length > 0 then match.upvoter_ids = $all: selected_upvoter_ids
    match.model = 'question'
    # match.answer_ids = $in:[Meteor.userId()]

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

    self.ready()


Meteor.publish 'facet_docs', (
    selected_tags
    selected_upvoter_ids
    )->

    self = @
    match = {}
    if selected_tags.length > 0 then match.tags = $all: selected_tags
    # if selected_upvoter_ids.length > 0 then match.upvoter_ids = $all: selected_upvoter_ids
    match.upvoter_ids = $all: selected_upvoter_ids

    # match.answer_ids = $nin:[Meteor.userId()]

    match.model = 'question'
    Docs.find match,
        sort:_timestamp:1
        limit: 5


Meteor.publish 'users', ->
    Meteor.users.find()
