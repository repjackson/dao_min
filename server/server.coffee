Meteor.users.allow
    insert: (user_id, doc, fields, modifier) ->
        # user_id
        true
        # if user_id and doc._id == user_id
        #     true
    update: (user_id, doc, fields, modifier) ->
        true
        # if user_id and doc._id == user_id
        #     true
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
        if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
            true
        else
            doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles






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

        # console.log result
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

        # console.log result
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
