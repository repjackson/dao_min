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
        answered_count = Docs.find(match).count()
        answered_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                answered_cloud:answered_cloud
                answered_count:answered_count

    calc_user_unanswered_question_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.answered_user_ids = $nin:[Meteor.userId()]
        unanswered_count = Docs.find(match).count()
        unanswered_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                unanswered_cloud:unanswered_cloud
                unanswered_count:unanswered_count

    calc_user_liked_question_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.upvoter_ids = $in:[Meteor.userId()]
        liked_count = Docs.find(match).count()
        liked_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                liked_cloud:liked_cloud
                liked_count:liked_count

    calc_user_disliked_question_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.downvoter_ids = $in:[Meteor.userId()]
        disliked_count = Docs.find(match).count()
        disliked_cloud = Meteor.call 'user_stats_agg', match
        Meteor.users.update user_id,
            $set:
                disliked_cloud:disliked_cloud
                disliked_count:disliked_count





    calc_user_yes_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        yes_answers = Docs.find({
            model:'answer_session'
            boolean_choice: true
            _author_id: user_id
            })
        yes_count = yes_answers.count()

        question_ids = []
        for answer in yes_answers.fetch()
            console.log answer
            question_ids.push answer.question_id
        # console.log question_ids

        match = {}
        match.model = 'question'
        match._id = $in: question_ids
        yes_cloud = Meteor.call 'user_stats_agg', match
        yes_questions = Docs.find(
            _id:$in:question_ids
        ).fetch()
        # console.log yes_questions

        # console.log 'yes cloud', yes_cloud
        Meteor.users.update user_id,
            $set:
                yes_cloud:yes_cloud
                yes_count:yes_count

    calc_user_no_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        no_answers = Docs.find({
            model:'answer_session'
            boolean_choice: false
            _author_id: user_id
            })
        no_count = no_answers.count()

        question_ids = []
        for answer in no_answers.fetch()
            question_ids.push answer.question_id
        # console.log question_ids

        match = {}
        match.model = 'question'
        match._id = $in: question_ids
        no_cloud = Meteor.call 'user_stats_agg', match
        no_questions = Docs.find(
            _id:$in:question_ids
        ).fetch()
        # console.log no_questions

        # console.log 'no cloud', no_cloud
        Meteor.users.update user_id,
            $set:
                no_cloud:no_cloud
                no_count:no_count

    calc_user_correct_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        correct_answers = Docs.find({
            model:'answer_session'
            is_correct_answer: true
            _author_id: user_id
            })
        correct_count = correct_answers.count()
        question_ids = []
        for answer in correct_answers.fetch()
            question_ids.push answer.question_id
        # console.log question_ids

        match = {}
        match.model = 'question'
        match._id = $in: question_ids
        correct_cloud = Meteor.call 'user_stats_agg', match
        # correct_questions = Docs.find(
        #     _id:$in:correct_cloud
        # ).fetch()
        # console.log correct_questions
        correct_list = _.pluck(correct_cloud, 'name')

        # console.log 'correct cloud', correct_cloud
        Meteor.users.update user_id,
            $set:
                correct_count: correct_count
                correct_cloud: correct_cloud
                correct_list: correct_list

    calc_user_incorrect_answer_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        incorrect_answers = Docs.find({
            model:'answer_session'
            is_correct_answer: false
            _author_id: user_id
            })
        question_ids = []
        incorrect_count = incorrect_answers.count()
        for answer in incorrect_answers.fetch()
            question_ids.push answer.question_id
        # console.log question_ids

        match = {}
        match.model = 'question'
        match._id = $in: question_ids
        incorrect_cloud = Meteor.call 'user_stats_agg', match
        # incorrect_questions = Docs.find(
        #     _id:$in:incorrect_cloud
        # ).fetch()
        # console.log incorrect_questions

        # console.log 'incorrect cloud', incorrect_cloud
        Meteor.users.update user_id,
            $set:
                incorrect_cloud:incorrect_cloud
                incorrect_count:incorrect_count




    user_stats_agg: (match)->
        limit=10
        # console.log 'agging', match
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
