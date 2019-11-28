Meteor.methods
    calc_user_up_cloud: (user_id)->
        user = Meteor.users.findOne user_id
        match = {}
        match.model = 'question'
        match.upvoter_ids = $in:[Meteor.userId()]
        up_count = Docs.find(match).count()
        up_cloud = Meteor.call 'user_stats_agg', match
        up_list = _.pluck(up_cloud, 'name')
        Meteor.users.update user_id,
            $set:
                up_cloud:up_cloud
                up_count:up_count
                up_list:up_list


    user_stats_agg: (match)->
        limit=42
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
