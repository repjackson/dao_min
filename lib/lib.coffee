@Docs = new Meteor.Collection 'docs'
@Tags = new Meteor.Collection 'tags'
@Upvoters = new Meteor.Collection 'upvoters'


Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false


Router.route '*', -> @render 'not_found'

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'






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
    upvoters = []
    downvoters = []
    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array

    return




# Docs.helpers
#     when: -> moment(@_timestamp).fromNow()

if Meteor.isServer
    Meteor.publish 'doc', (id)-> Docs.find id
    Meteor.publish 'docs', (selected_tags)->
        self = @
        match = {}
        if selected_tags.length > 0 then match.tags = $all:selected_tags

        Docs.find match, sort:_timestamp:-1


Meteor.methods
    upvote: (doc)->
        if Meteor.user().username
            if doc.downvoters and Meteor.user().username in doc.downvoters
                Docs.update doc._id,
                    $pull:
                        downvoters:Meteor.user().username
                    $addToSet:
                        upvoters:Meteor.user().username
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoters and Meteor.user().username in doc.upvoters
                Docs.update doc._id,
                    $pull:
                        upvoters:Meteor.user().username
                        answered:Meteor.user().username
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet:
                        upvoters:Meteor.user().username
                        answered:Meteor.user().username
                    $inc:
                        upvotes:1
                        points:1
            Meteor.users.update doc._author_id,
                $inc:karma:1

    downvote: (doc)->
        if Meteor.user().username
            if doc.upvoters and Meteor.user().username in doc.upvoters
                Docs.update doc._id,
                    $pull:
                        upvoters:Meteor.user().username
                    $addToSet:
                        downvoters:Meteor.user().username
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoters and Meteor.user().username in doc.downvoters
                Docs.update doc._id,
                    $pull:
                        downvoters:Meteor.user().username
                        answered:Meteor.user().username
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet:
                        downvoters:Meteor.user().username
                        answered:Meteor.user().username
                    $inc:
                        points:-1
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:karma:-1
