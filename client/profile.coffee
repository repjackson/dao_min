Router.route '/user/:user_id', (->
    @layout 'profile_layout'
    @render 'user_dashboard'
    ), name:'user_dashboard'


Template.profile_layout.onCreated ->
    @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.user_id
    @autorun -> Meteor.subscribe 'user_stats', Router.current().params.user_id
Template.profile_layout.onRendered ->
    # Meteor.setTimeout ->
    #     $('.button').popup()
    # , 2000
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.profile_layout.helpers
    user: ->
        Meteor.users.findOne Router.current().params.user_id

Template.user_dashboard.onCreated ->
    @autorun -> Meteor.subscribe 'user_up_questions', Router.current().params.user_id
Template.user_dashboard.onRendered ->
    Meteor.call 'calc_user_up_cloud', Router.current().params.user_id


Template.nav.events
    'click .recalc_stats': ->
        Meteor.call 'calc_user_up_cloud', Router.current().params.user_id


Template.user_dashboard.helpers
    ssd: ->
        user = Meteor.users.findOne Router.current().params.user_id
        Docs.findOne
            model:'user_stats'
            user_id:user._id
    # answered_questions: ->
    #     Docs.find {
    #         model:'question'
    #         answered_user_ids: $in:[Meteor.userId()]
    #     }, sort: _timestamp: -1
    upvotes: ->
        Docs.find {
            model:'question'
            upvoter_ids:$in:[Meteor.userId()]
        }, sort: _timestamp: -1


Template.profile_layout.events
    'click .recalc_user_up_cloud': ->
        Meteor.call 'recalc_user_up_cloud', Router.current().params.user_id
    'click .logout_other_clients': ->
        Meteor.logoutOtherClients()
    'click .logout': ->
        Session.set 'logging_out', true
        Router.go '/login'
        Meteor.logout()
        Session.set 'logging_out', false
