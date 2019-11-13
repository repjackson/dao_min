@selected_tags = new ReactiveArray []
Template.registerHelper 'is_loading', (number) -> Session.get('loading')
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'ten_tags', () -> @tags[..10]
Template.registerHelper 'five_tags', () -> @tags[..4]
Template.registerHelper 'sorted_tags', () -> @tags.sort()
Template.registerHelper 'is_pro', () -> Meteor.isProduction
Template.donate.onCreated ->
    # @autorun => Meteor.subscribe 'model_docs', 'donation'
    if Meteor.isDevelopment
        pub_key = Meteor.settings.public.stripe_test_publishable
    else if Meteor.isProduction
        pub_key = Meteor.settings.public.stripe_live_publishable
    Template.instance().checkout = StripeCheckout.configure(
        key: pub_key
        # image: 'https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/mmmlogo.png'
        locale: 'auto'
        # zipCode: true
        token: (token) ->
            donate_amount = parseInt $('.donate_amount').val()*100
            charge =
                amount: donate_amount
                currency: 'usd'
                source: token.id
                description: token.description
            Meteor.call 'donate', charge, (error, response) =>
                if error then alert error.reason, 'danger'
                else
                    alert 'donation received, thank you', 'success'
	)

Template.donate.events
    'click .start_donation': ->
        donation_amount = parseInt $('.donate_amount').val()*100
        Template.instance().checkout.open
            name: 'dao donation'
            # email:Meteor.user().emails[0].address
            # description: 'mmm donation'
            amount: donation_amount



Template.home.events
    'click .import_subreddit': ->
        subreddit = $('.subreddit').val()
        Meteor.call 'pull_subreddit', subreddit
    'keyup .subreddit': (e,t)->
        if e.which is 13
            subreddit = $('.subreddit').val()
            Meteor.call 'pull_subreddit', subreddit
    'click .import_site': ->
        site = $('.site').val()
        Meteor.call 'import_site', site
    'click .toggle_dev': ->
        Session.set('dev',!Session.get('dev'))
    'click .delete_doc': ->
        Docs.remove @_id

# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable



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
Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'
Template.registerHelper 'author', () -> Meteor.users.findOne @_author_id
Template.registerHelper 'decode', (input)->
    doc = new DOMParser().parseFromString(input, "text/html");
    doc.documentElement.textContent;

Template.registerHelper 'decoded_html', (input)->
    # console.log @
    # console.log @html
    doc = new DOMParser().parseFromString(@html, "text/html");
    doc.documentElement.textContent;

Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)

Template.registerHelper 'in_dev', -> Meteor.isDevelopment

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()
Template.registerHelper 'calculated_size', (metric) ->
    # console.log metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log whole

    if whole is 2 then 'f2'
    else if whole is 3 then 'f3'
    else if whole is 4 then 'f4'
    else if whole is 5 then 'f5'
    else if whole is 6 then 'f6'
    else if whole is 7 then 'f7'
    else if whole is 8 then 'f8'
    else if whole is 9 then 'f9'
    else if whole is 10 then 'f10'
