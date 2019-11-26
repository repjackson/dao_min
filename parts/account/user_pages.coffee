if Meteor.isClient
    Template.user_correct.onCreated ->
        @autorun -> Meteor.subscribe 'user_correct_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe 'model_docs', 'union'
    Template.user_correct.helpers
        correct_answers: ->
            Docs.find {
                model:'answer_session'
                is_correct_answer:true
                _author_id: Router.current().params.user_id
            }, sort: _timestamp: -1

        union_doc: ->
            Docs.findOne
                model:'union'
                user_ids:$all:[Meteor.userId(), Router.current().params.user_id]

    Template.user_correct.events
        'click .calc_correct_overlap': ->
            Meteor.call 'calc_user_correct_answer_cloud', Meteor.userId()
            Meteor.call 'calc_user_correct_answer_cloud', Router.current().params.user_id
            Meteor.call 'calc_correct_union', Meteor.userId(), Router.current().params.user_id





    Template.user_incorrect.onCreated ->
        @autorun -> Meteor.subscribe 'user_incorrect_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe 'model_docs', 'union'
    Template.user_incorrect.helpers
        incorrect_answers: ->
            Docs.find {
                model:'answer_session'
                is_correct_answer:false
                _author_id: Router.current().params.user_id
            }, sort: _timestamp: -1

        union_doc: ->
            Docs.findOne
                model:'union'
                user_ids:$all:[Meteor.userId(), Router.current().params.user_id]

    Template.user_incorrect.events
        'click .calc_incorrect_overlap': ->
            Meteor.call 'calc_user_incorrect_answer_cloud', Meteor.userId()
            Meteor.call 'calc_user_incorrect_answer_cloud', Router.current().params.user_id
            Meteor.call 'calc_incorrect_union', Meteor.userId(), Router.current().params.user_id



    Template.user_yes.onCreated ->
        @autorun -> Meteor.subscribe 'user_yes_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe 'model_docs', 'union'
    Template.user_yes.helpers
        yes_answers: ->
            Docs.find {
                model:'answer_session'
                is_correct_answer:false
                _author_id: Router.current().params.user_id
            }, sort: _timestamp: -1

        union_doc: ->
            Docs.findOne
                model:'union'
                user_ids:$all:[Meteor.userId(), Router.current().params.user_id]

    Template.user_yes.events
        'click .calc_yes_overlap': ->
            Meteor.call 'calc_user_yes_answer_cloud', Meteor.userId()
            Meteor.call 'calc_user_yes_answer_cloud', Router.current().params.user_id
            Meteor.call 'calc_yes_union', Meteor.userId(), Router.current().params.user_id



if Meteor.isServer
    Meteor.methods
        calc_correct_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().correct_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.correct_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.correct_cloud, {name: term})
                my_count = _.findWhere(me.correct_cloud, {name: term})
                # console.log other_count
                # console.log my_count
                union_points += my_count.count
                union_points += other_count.count
                term_summed_count = {}
                term_summed_count.name = term
                term_summed_count.count = other_count.count + my_count.count
                result.push term_summed_count

            console.log result
            union_doc  = Docs.findOne({
                model:'union'
                user_ids:$all:[user1_id, user2_id]
            })
            unless union_doc
                new_union_id = Docs.insert
                    model:'union'
                    user_ids:[user1_id, user2_id]
                union_doc = Docs.findOne new_union_id
            union_doc  = Docs.update(
                {
                    _id:union_doc._id
                }, {
                    $set:
                        correct_cloud: result
                        correct_list: intersection
                        correct_points: union_points
                })


        calc_incorrect_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().incorrect_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.incorrect_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.incorrect_cloud, {name: term})
                my_count = _.findWhere(me.incorrect_cloud, {name: term})
                # console.log other_count
                # console.log my_count
                union_points += my_count.count
                union_points += other_count.count
                term_summed_count = {}
                term_summed_count.name = term
                term_summed_count.count = other_count.count + my_count.count
                result.push term_summed_count

            console.log result
            union_doc  = Docs.findOne({
                model:'union'
                user_ids:$all:[user1_id, user2_id]
            })
            unless union_doc
                new_union_id = Docs.insert
                    model:'union'
                    user_ids:[user1_id, user2_id]
                union_doc = Docs.findOne new_union_id
            union_doc  = Docs.update(
                {
                    _id:union_doc._id
                }, {
                    $set:
                        incorrect_cloud: result
                        incorrect_list: intersection
                        incorrect_points: union_points
                })



        calc_yes_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().yes_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.yes_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.yes_cloud, {name: term})
                my_count = _.findWhere(me.yes_cloud, {name: term})
                # console.log other_count
                # console.log my_count
                union_points += my_count.count
                union_points += other_count.count
                term_summed_count = {}
                term_summed_count.name = term
                term_summed_count.count = other_count.count + my_count.count
                result.push term_summed_count

            console.log result
            union_doc  = Docs.findOne({
                model:'union'
                user_ids:$all:[user1_id, user2_id]
            })
            unless union_doc
                new_union_id = Docs.insert
                    model:'union'
                    user_ids:[user1_id, user2_id]
                union_doc = Docs.findOne new_union_id
            union_doc  = Docs.update(
                {
                    _id:union_doc._id
                }, {
                    $set:
                        yes_cloud: result
                        yes_list: intersection
                        yes_points: union_points
                })



        calc_no_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().no_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.no_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.no_cloud, {name: term})
                my_count = _.findWhere(me.no_cloud, {name: term})
                # console.log other_count
                # console.log my_count
                union_points += my_count.count
                union_points += other_count.count
                term_summed_count = {}
                term_summed_count.name = term
                term_summed_count.count = other_count.count + my_count.count
                result.push term_summed_count

            console.log result
            union_doc  = Docs.findOne({
                model:'union'
                user_ids:$all:[user1_id, user2_id]
            })
            unless union_doc
                new_union_id = Docs.insert
                    model:'union'
                    user_ids:[user1_id, user2_id]
                union_doc = Docs.findOne new_union_id
            union_doc  = Docs.update(
                {
                    _id:union_doc._id
                }, {
                    $set:
                        no_cloud: result
                        no_list: intersection
                        no_points: union_points
                })


        calc_liked_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().liked_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.liked_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.liked_cloud, {name: term})
                my_count = _.findWhere(me.liked_cloud, {name: term})
                # console.log other_count
                # console.log my_count
                union_points += my_count.count
                union_points += other_count.count
                term_summed_count = {}
                term_summed_count.name = term
                term_summed_count.count = other_count.count + my_count.count
                result.push term_summed_count

            console.log result
            union_doc  = Docs.findOne({
                model:'union'
                user_ids:$all:[user1_id, user2_id]
            })
            unless union_doc
                new_union_id = Docs.insert
                    model:'union'
                    user_ids:[user1_id, user2_id]
                union_doc = Docs.findOne new_union_id
            union_doc  = Docs.update(
                {
                    _id:union_doc._id
                }, {
                    $set:
                        liked_cloud: result
                        liked_list: intersection
                        liked_points: union_points
                })


        calc_disliked_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().disliked_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.disliked_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.disliked_cloud, {name: term})
                my_count = _.findWhere(me.disliked_cloud, {name: term})
                # console.log other_count
                # console.log my_count
                union_points += my_count.count
                union_points += other_count.count
                term_summed_count = {}
                term_summed_count.name = term
                term_summed_count.count = other_count.count + my_count.count
                result.push term_summed_count

            console.log result
            union_doc  = Docs.findOne({
                model:'union'
                user_ids:$all:[user1_id, user2_id]
            })
            unless union_doc
                new_union_id = Docs.insert
                    model:'union'
                    user_ids:[user1_id, user2_id]
                union_doc = Docs.findOne new_union_id
            union_doc  = Docs.update(
                {
                    _id:union_doc._id
                }, {
                    $set:
                        disliked_cloud: result
                        disliked_list: intersection
                        disliked_points: union_points
                })
