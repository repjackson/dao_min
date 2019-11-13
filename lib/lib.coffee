@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Subreddits = new Meteor.Collection 'subreddits'

@Bug_tags = new Meteor.Collection 'bug_tags'
@Rental_tags = new Meteor.Collection 'rental_tags'
@Task_tags = new Meteor.Collection 'task_tags'
@Shop_tags = new Meteor.Collection 'shop_tags'
@Question_tags = new Meteor.Collection 'question_tags'
@Test_tags = new Meteor.Collection 'test_tags'
@User_section_tags = new Meteor.Collection 'user_section_tags'

Docs.before.insert (userId, doc)->
    if Meteor.user()
        doc._author_id = Meteor.userId()
        doc._author_username = Meteor.user().username

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


Docs.helpers
    when: -> moment(@_timestamp).fromNow()

if Meteor.isServer
    Docs.allow
        # insert: (userId, doc) -> userId
        # update: (userId, doc) -> userId is @_author_id
        # remove: (userId, doc) -> userId is @_author_id
        insert: (userId, doc) ->
            if doc.model is 'bug'
                true
            else
                userId and doc._author_id is userId
        update: (userId, doc) ->
            if doc.model in ['calculator_doc','credit_type', 'debit_type']
                true
            else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
                true
            else
                doc._author_id is userId
        # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
        remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles

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
