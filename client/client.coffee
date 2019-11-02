@selected_tags = new ReactiveArray []

Template.cloud.onCreated ->
    @autorun -> Meteor.subscribe('tags', selected_tags.array())
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe('facet_docs',selected_tags.array())

Template.home.helpers
    docs: ->
        doc_count = Docs.find().count()
        if doc_count is 1
            Docs.find {
            }
Template.cloud.helpers
    all_tags: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find({},{limit:100})
    cloud_tag_class: ->
        button_class = switch
            when @index <= 5 then 'large'
            when @index <= 12 then ''
            when @index <= 20 then 'small'
        return button_class
    selected_tags: -> selected_tags.array()
    settings: -> {
        position: 'bottom'
        limit: 10
        rules: [
            {
                collection: Tags
                field: 'name'
                matchAll: true
                template: Template.tag_result
            }
        ]
    }


Template.cloud.events
    'click .select_tag': -> selected_tags.push @name
    'click .unselect_tag': -> selected_tags.remove @valueOf()
    'click #clear_tags': -> selected_tags.clear()

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_tags.pop()

    'autocompleteselect #search': (event, template, doc) ->
        selected_tags.push doc.name
        $('#search').val ''

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
                    # Docs.insert
                    #     model:'donation'
                    #     amount:donate_amount/100
                    #     message:message
                    #     receipt_email: email
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
