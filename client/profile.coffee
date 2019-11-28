Template.layout.onCreated ->
    @autorun -> Meteor.subscribe 'user_from_id', Meteor.userId()
    @autorun -> Meteor.subscribe 'user_stats', Meteor.userId()
Template.layout.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion()
    , 1000

Template.layout.helpers
    user: -> Meteor.users.findOne Meteor.userId()

# Template.user_dashboard.onCreated ->
#     @autorun -> Meteor.subscribe 'user_up_questions', Meteor.userId()
# Template.user_dashboard.onRendered ->
#     Meteor.call 'calc_user_up_cloud', Meteor.userId()


Template.nav.events
    'click .recalc_stats': ->
        Meteor.call 'calc_user_up_cloud', Meteor.userId()


# Template.user_dashboard.helpers
#     upvotes: ->
#         Docs.find {
#             model:'question'
#             upvoter_ids:$in:[Meteor.userId()]
#         }, sort: _timestamp: -1


Template.layout.events
    'click .recalc_user_up_cloud': ->
        Meteor.call 'recalc_user_up_cloud', Meteor.userId()
    'click .logout_other_clients': ->
        Meteor.logoutOtherClients()
    'click .logout': ->
        Session.set 'logging_out', true
        Router.go '/login'
        Meteor.logout()
        Session.set 'logging_out', false
