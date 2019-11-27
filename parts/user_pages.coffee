if Meteor.isClient
    Template.user_up.onCreated ->
        @autorun -> Meteor.subscribe 'user_up_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe 'model_docs', 'union'
    Template.user_up.helpers
        up_answers: ->
            Docs.find {
                upvoter_ids:$in:[Meteor.userId()]
            }, sort: _timestamp: -1

        union_doc: ->
            Docs.findOne
                model:'union'
                user_ids:$all:[Meteor.userId(), Router.current().params.user_id]
    Template.user_up.events
        'click .calc_up_overlap': ->
            Meteor.call 'calc_user_up_cloud', Meteor.userId()
            Meteor.call 'calc_user_up_cloud', Router.current().params.user_id
            Meteor.call 'calc_up_union', Meteor.userId(), Router.current().params.user_id


    Template.user_down.onCreated ->
        @autorun -> Meteor.subscribe 'user_down_answers', Router.current().params.user_id
        @autorun -> Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe 'model_docs', 'union'
    Template.user_down.helpers
        down_answers: ->
            Docs.find {
                downvoter_ids:$in:[Meteor.userId()]
            }, sort: _timestamp: -1

        union_doc: ->
            Docs.findOne
                model:'union'
                user_ids:$all:[Meteor.userId(), Router.current().params.user_id]
    Template.user_down.events
        'click .calc_down_overlap': ->
            Meteor.call 'calc_user_down_cloud', Meteor.userId()
            Meteor.call 'calc_user_down_cloud', Router.current().params.user_id
            Meteor.call 'calc_down_union', Meteor.userId(), Router.current().params.user_id



if Meteor.isServer
    Meteor.methods
        calc_up_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().up_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.up_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.up_cloud, {name: term})
                my_count = _.findWhere(me.up_cloud, {name: term})
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
                        up_cloud: result
                        up_list: intersection
                        up_points: union_points
                })


        calc_down_union: (user1_id, user2_id)->
            me = Meteor.users.findOne user1_id
            my_tag_list = Meteor.user().down_list
            target = Meteor.users.findOne user2_id
            target_tag_list = target.down_list

            result = []

            intersection = _.intersection(my_tag_list, target_tag_list)
            union_points = 0
            for term in intersection
                other_count = _.findWhere(target.down_cloud, {name: term})
                my_count = _.findWhere(me.down_cloud, {name: term})
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
                        down_cloud: result
                        down_list: intersection
                        down_points: union_points
                })
