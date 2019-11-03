Future = Npm.require('fibers/future')

Meteor.methods
    donate: (charge) ->
        if Meteor.isDevelopment
            Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
        else
            Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
        chargeCard = new Future

        chargeData =
            amount: charge.amount
            currency: 'usd'
            source: charge.source
            description: "dao donation"
            # destination: account.stripe.stripeId
        Stripe.charges.create chargeData, (error, result) ->
            if error
                chargeCard.return error: error
            else
                chargeCard.return result: result
            return
        newCharge = chargeCard.wait()
        console.log newCharge
        newCharge
