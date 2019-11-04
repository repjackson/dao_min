@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Usernames = new Meteor.Collection 'usernames'
@Subreddits = new Meteor.Collection 'subreddits'


Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    return


Meteor.users.helpers
    name: ->
        if @nickname
            "#{@nickname}"
        else if @first_name and @last_name
            "#{@first_name} #{@last_name}"
        else
            "#{@username}"
    is_current_student: ->
        if @roles
            if 'admin' in @roles
                if 'student' in @current_roles then true else false
            else
                if 'student' in @roles then true else false

    email_address: -> if @emails and @emails[0] then @emails[0].address
    email_verified: -> if @emails and @emails[0] then @emails[0].verified
    five_tags: -> if @tags then @tags[..4]
    three_tags: -> if @tags then @tags[..2]
    last_name_initial: -> if @last_name then @last_name.charAt 0




Docs.helpers
    when: -> moment(@_timestamp).fromNow()

if Meteor.isServer
    Docs.allow
        insert: (userId, doc) -> userId
        update: (userId, doc) -> userId is @_author_id
        remove: (userId, doc) -> userId is @_author_id

    Meteor.publish 'doc', (id)->
        doc = Docs.findOne id
        user = Meteor.users.findOne id
        if doc
            Docs.find id
        else if user
            Meteor.users.find id
    Meteor.publish 'docs', (selected_tags, filter)->
        # console.log selected_tags
        # console.log filter
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        if filter then match.model = filter

        Docs.find match, sort:_timestamp:-1






Meteor.methods
    add_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            new_facet_ob = {
                key:filter
                filters:[]
                res:[]
            }
            Docs.update { _id:delta_id },
                $addToSet: facets: new_facet_ob
        Docs.update { _id:delta_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'fum', delta_id, (err,res)->


    remove_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            Docs.update { _id:delta_id },
                $pull:facets: {key:filter}
        Docs.update { _id:delta_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fum', delta_id, (err,res)->



    pin: (doc)->
        if doc.pinned_ids and Meteor.userId() in doc.pinned_ids
            Docs.update doc._id,
                $pull: pinned_ids: Meteor.userId()
                $inc: pinned_count: -1
        else
            Docs.update doc._id,
                $addToSet: pinned_ids: Meteor.userId()
                $inc: pinned_count: 1

    subscribe: (doc)->
        if doc.subscribed_ids and Meteor.userId() in doc.subscribed_ids
            Docs.update doc._id,
                $pull: subscribed_ids: Meteor.userId()
                $inc: subscribed_count: -1
        else
            Docs.update doc._id,
                $addToSet: subscribed_ids: Meteor.userId()
                $inc: subscribed_count: 1


    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: upvoter_ids:Meteor.userId()
                    $inc:
                        upvotes:1
                        points:1
            Meteor.users.update doc._author_id,
                $inc:karma:1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:1
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:1

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: upvoter_ids:Meteor.userId()
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: downvoter_ids:Meteor.userId()
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: downvoter_ids:Meteor.userId()
                    $inc:
                        points:-1
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:karma:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:-1
