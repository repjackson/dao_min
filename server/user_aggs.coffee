Meteor.methods
    calc_user_stats: (user_id)->
        Meteor.call 'calc_user_answered_question_cloud', user_id
        Meteor.call 'calc_user_unanswered_question_cloud', user_id
        Meteor.call 'calc_user_liked_question_cloud', user_id
        Meteor.call 'calc_user_disliked_question_cloud', user_id
        Meteor.call 'calc_user_correct_answer_cloud', user_id
        Meteor.call 'calc_user_incorrect_answer_cloud', user_id
        Meteor.call 'calc_user_yes_answer_cloud', user_id
        Meteor.call 'calc_user_no_answer_cloud', user_id

    calc_user_answered_question_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.answered_user_ids = $in:[Meteor.userId()]
        answered_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                answered_cloud:answered_cloud

    calc_user_unanswered_question_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.answered_user_ids = $nin:[Meteor.userId()]
        unanswered_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                unanswered_cloud:unanswered_cloud

    calc_user_liked_question_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.upvoter_ids = $in:[Meteor.userId()]
        liked_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                liked_cloud:liked_cloud

    calc_user_disliked_question_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.downvoter_ids = $nin:[Meteor.userId()]
        disliked_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                disliked_cloud:disliked_cloud





    calc_user_yes_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        yes_answers = Docs.find({
            model:'answer_session'
            boolean_choice: true
            _author_id: user_id
            }).fetch()
        question_ids = []
        for answer in yes_answers
            question_ids.push answer._id
        console.log question_ids

        match = {}
        match.model = 'question'
        match._id = $in: question_ids
        yes_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set: yes_cloud:yes_cloud

    calc_user_no_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'answer_session'
        match._author_id = user_id
        match.boolean_choice = false
        no_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set: no_cloud:no_cloud



    calc_user_correct_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'answer_session'
        match._author_id = user_id
        match.is_correct_answer = true
        correct_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set: correct_cloud:correct_cloud

    calc_user_incorrect_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'answer_session'
        match._author_id = user_id
        match.is_correct_answer = false
        incorrect_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set: incorrect_cloud:incorrect_cloud




    user_stats_agg: (match)->
        limit=10
        options = { explain:false }
        pipe =  [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
        else
            return null
