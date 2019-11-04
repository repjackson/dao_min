@selected_tags = new ReactiveArray []
@selected_usernames = new ReactiveArray []
@selected_subreddits = new ReactiveArray []
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
Template.registerHelper 'ten_tags', () -> @tags[..10]
Template.registerHelper 'five_tags', () -> @tags[..4]
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




Template.home.events
    'click .import_subreddit': ->
        subreddit = $('.subreddit').val()
        Meteor.call 'pull_subreddit', subreddit
    'click .import_site': ->
        site = $('.site').val()
        Meteor.call 'import_site', site
    'click .toggle_dev': ->
        Session.set('dev',!Session.get('dev'))
    'click .delete_doc': ->
        Docs.remove @_id
Template.tag_label.events
    'click .remove_tag': ->
        console.log @valueOf()
        console.log Template.parentData()
        Docs.update Template.parentData()._id,
            $pull: tags: @valueOf()
Template.home.helpers
    dev_mode: -> Session.get('dev')
    docs: ->
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find {
        }

# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable

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
                    alert 'thank you', 'success'
	)

Template.donate.helpers
    donations: ->
        Docs.find {
            model:'donation'
        }, _timestamp:1
Template.donate.events
    'click .start_donation': ->
        donation_amount = parseInt $('.donate_amount').val()*100
        Template.instance().checkout.open
            name: 'dao donation'
            # email:Meteor.user().emails[0].address
            # description: 'mmm donation'
            amount: donation_amount


Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'is_dev', () ->
    if Meteor.user() and Meteor.user().roles
        if 'dev' in Meteor.user().roles then true else false
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
Template.registerHelper 'last_initial', (user) ->
    @last_name[0]+'.'
Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'
Template.registerHelper 'author', () -> Meteor.users.findOne @_author_id
Template.registerHelper 'fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        match = {}
        # if Meteor.user()
        #     match.view_roles = $in:Meteor.user().roles
        match.model = 'field'
        match.parent_id = model._id
        # console.log model
        cur = Docs.find match,
            sort:rank:1
        # console.log cur.fetch()
        cur

Template.registerHelper 'edit_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            edit_roles:$in:Meteor.user().roles
        }, sort:rank:1

Template.registerHelper 'sortable_fields', () ->
    model = Docs.findOne
        model:'model'
        slug:Router.current().params.model_slug
    if model
        Docs.find {
            model:'field'
            parent_id:model._id
            sortable:true
        }, sort:rank:1
Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'current_model', (input) ->
    Docs.findOne
        model:'model'
        slug: Router.current().params.model_slug
Template.registerHelper 'is_current_admin', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','admin'], Meteor.user().roles) then true else false
        if 'admin' in Meteor.user().current_roles then true else false
Template.registerHelper 'is_admin', () ->
    if Meteor.user() and Meteor.user().roles
        # if _.intersection(['dev','admin'], Meteor.user().roles) then true else false
        if 'admin' in Meteor.user().roles then true else false
Template.registerHelper 'is_eric', () -> if Meteor.userId() and Meteor.userId() in ['exYMs7xwuJ9QZJZ33'] then true else false

Template.registerHelper 'current_user', () ->  Meteor.users.findOne username:Router.current().params.username
Template.registerHelper 'is_current_user', () ->
    if Meteor.user().username is Router.current().params.username
        true
    else
        if Meteor.user().roles and 'dev' in Meteor.user().roles
            true
        else
            false
Template.registerHelper 'view_template', -> "#{@field_type}_view"
Template.registerHelper 'edit_template', -> "#{@field_type}_edit"
Template.registerHelper 'is_model', -> @model is 'model'
Template.registerHelper 'is_editing', () -> Session.equals 'editing_id', @_id
Template.registerHelper 'editing_doc', () ->
    Docs.findOne Session.get('editing_id')

Template.registerHelper 'can_edit', () ->
    if Meteor.user()
        Meteor.userId() is @_author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'current_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    user = Meteor.users.findOne Router.current().params.doc_id
    # console.log doc
    # console.log user
    if doc then doc else if user then user

Template.registerHelper 'page_doc', ->
    doc = Docs.findOne Router.current().params.doc_id
    if doc then doc

Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5
        if parent5._id
            parent = Template.parentData(5)
    else if parent6
        if parent6._id
            parent = Template.parentData(6)
    if parent
        parent["#{@key}"]


Template.registerHelper 'sorted_field_values', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5._id
        parent = Template.parentData(5)
    else if parent6._id
        parent = Template.parentData(6)
    if parent
        _.sortBy parent["#{@key}"], 'number'
