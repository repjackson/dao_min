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
    Meteor.publish 'docs', (selected_theme_tags, filter)->
        # console.log selected_theme_tags
        # console.log filter
        self = @
        match = {}
        if selected_theme_tags.length > 0 then match.tags = $all: selected_theme_tags
        if filter then match.model = filter

        Docs.find match, sort:_timestamp:-1
