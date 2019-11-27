@selected_tags = new ReactiveArray []
@selected_question_tags = new ReactiveArray []



Template.registerHelper 'facet_tags', () ->
    if Session.get('loading', true) then 'disabled' else ''
Template.registerHelper 'first_initial', (user) ->
    @first_name[..2]+'.'
    # moment(input).fromNow()
Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
Template.registerHelper 'current_user', () ->  Meteor.users.findOne Router.current().params.user_id
Template.registerHelper 'is_current_user', () ->
    if Meteor.userId() is Router.current().params.user_id
        true
    else
        if Meteor.user().roles and 'dev' in Meteor.user().roles
            true
        else
            false

Template.registerHelper 'is_loading', (number) -> Session.get('loading')
Template.registerHelper 'loading_class', () ->
    if Session.equals('loading', true)
        'loading disabled'
    else
        ''


Template.registerHelper 'can_edit', () ->
    if Meteor.userId()
        if Meteor.user().roles and 'admin' in Meteor.user().roles
            true
        else if @_author_id is Meteor.userId()
            true

Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'ten_tags', () -> @tags[..10]
Template.registerHelper 'five_tags', () -> @tags[..4]
Template.registerHelper 'sorted_tags', () -> @tags.sort()
Template.registerHelper 'is_pro', () -> Meteor.isProduction
Template.registerHelper 'current_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    user = Meteor.users.findOne Router.current().params.doc_id
    # console.log doc
    # console.log user
    if doc then doc else if user then user

# Template.donate_quick.onCreated ->
#     # @autorun => Meteor.subscribe 'model_docs', 'donation'
#     if Meteor.isDevelopment
#         pub_key = Meteor.settings.public.stripe_test_publishable
#     else if Meteor.isProduction
#         pub_key = Meteor.settings.public.stripe_live_publishable
#     Template.instance().checkout = StripeCheckout.configure(
#         key: pub_key
#         # image: 'https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/mmmlogo.png'
#         locale: 'auto'
#         # zipCode: true
#         token: (token) ->
#             donate_amount = parseInt $('.donate_amount').val()*100
#             charge =
#                 amount: donate_amount
#                 currency: 'usd'
#                 source: token.id
#                 description: token.description
#             Meteor.call 'donate', charge, (error, response) =>
#                 if error then alert error.reason, 'danger'
#                 else
#                     alert 'donation received, thank you', 'success'
# 	)
#
# Template.donate_quick.events
#     'click .start_donation': ->
#         donation_amount = parseInt $('.donate_amount').val()*100
#         Template.instance().checkout.open
#             name: 'dao donation'
#             # email:Meteor.user().emails[0].address
#             # description: 'mmm donation'
#             amount: donation_amount




# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable



Template.registerHelper 'question', () ->
    Docs.findOne @question_id

Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'is_dev', () ->
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles then true else false
Template.registerHelper 'is_admin', () ->
    if Meteor.user() and Meteor.user().roles
        if 'admin' in Meteor.user().roles then true else false
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
Template.registerHelper 'author', () -> Meteor.users.findOne @_author_id


Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)

Template.registerHelper 'in_dev', -> Meteor.isDevelopment

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()


Template.voting_full.events
    'click .upvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'upvote', @
    'click .downvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'downvote', @
Template.voting_full.helpers
    upvote_class: ->
        # console.log @
        if Meteor.userId() in @upvoter_ids then 'green' else 'outline'
    downvote_class: ->
        # console.log @
        if Meteor.userId() in @downvoter_ids then 'red' else 'outline'



Template.user_info.onCreated ->
    @autorun => Meteor.subscribe 'user_from_id', @data
Template.user_info.helpers
    user: -> Meteor.users.findOne @valueOf()
