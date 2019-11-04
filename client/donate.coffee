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
