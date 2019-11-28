Meteor.publish 'me', ->
    Meteor.users.find Meteor.userId()

Meteor.publish 'user_answered_questions', (user_id)->
    Docs.find
        model:'question'
        answer_ids: $in: [user_id]
Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'model_docs', (model)->
    Docs.find
        model:model

Meteor.publish 'user_up_questions', (user_id)->
    Docs.find
        model:'question'
        upvoter_ids: $in: [user_id]

Meteor.publish 'user_down_questions', (user_id)->
    Docs.find
        model:'question'
        downvoter_ids: $in: [user_id]

Meteor.publish 'user_stats', (user_id)->
    user = Meteor.users.findOne user_id
    if user
        Docs.find
            model:'user_stats'
            user_id:user._id


Meteor.publish 'tags', (
    selected_tags
    view_answered
    view_unanswered
    )->
    self = @
    match = {}

    # console.log selected_tags
    # console.log view_answered
    # console.log view_unanswered
    # if view_answered
    #     match.answer_ids = $in:[Meteor.userId()]
    # if view_unanswered
    #     match.answer_ids = $nin:[Meteor.userId()]

    if selected_tags.length > 0 then match.tags = $all: selected_tags
    match.model = 'question'
    match.answer_ids = $nin:[Meteor.userId()]
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
    view_answered
    view_unanswered
    )->

    # console.log selected_tags
    # console.log view_answered
    # console.log view_unanswered
    self = @
    match = {}
    # if view_answered
    #     match.answer_ids = $in:[Meteor.userId()]
    # if view_unanswered
    #     match.answer_ids = $nin:[Meteor.userId()]
    if selected_tags.length > 0 then match.tags = $all: selected_tags

    match.answer_ids = $nin:[Meteor.userId()]

    match.model = 'question'
    Docs.find match,
        sort:_timestamp:1
        limit: 5


Meteor.publish 'users', ->
    Meteor.users.find()
