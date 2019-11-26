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

        correct_list_overlap: ->
            my_tag_list = Meteor.user().correct_list
            target = Meteor.users.findOne Router.current().params.user_id
            target_tag_list = target.correct_list
            intersection = _.intersection(my_tag_list, target_tag_list)

        union_doc: ->
            Docs.findOne
                model:'union'
                user_ids:$all:[Meteor.userId(), Router.current().params.user_id]

    Template.user_correct.events
        'click .calc_correct_overlap': ->
            Meteor.call 'calc_user_correct_answer_cloud', Meteor.userId()
            Meteor.call 'calc_user_correct_answer_cloud', Router.current().params.user_id
            Meteor.call 'calc_correct_union', Meteor.userId(), Router.current().params.user_id



if Meteor.isServer
    Meteor.methods
        calc_correct_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().correct_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.correct_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            for term in intersection
                other_count = _.findWhere(target.correct_cloud, {name: term})
                my_count = _.findWhere(me.correct_cloud, {name: term})

                # console.log other_count
                # console.log my_count

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
            union_doc  = Docs.update({_id:union_doc._id}, {$set:correct_cloud:result})
