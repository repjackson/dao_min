if Meteor.isClient
    Router.route '/classroom/:doc_id/loans', (->
        @layout 'classroom_view_layout'
        @render 'classroom_loans'
        ), name:'classroom_loans'
    Router.route '/classroom/:classroom_id/loan/:doc_id/edit', (->
        @layout 'classroom_view_layout'
        @render 'loan_edit'
        ), name:'loan_edit'
    Router.route '/classroom/:classroom_id/loan/:doc_id/view', (->
        @layout 'classroom_view_layout'
        @render 'loan_view'
        ), name:'loan_view'



    Template.loan_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.loan_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.loan_edit.events

    Template.loan_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.loan_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->

    Template.classroom_loans.onRendered ->
        @autorun => Meteor.subscribe 'classroom_docs', 'loan', Router.current().params.doc_id
    Template.classroom_loans.helpers
        loans: ->
            Docs.find
                model:'loan'

    Template.classroom_loans.events
        'click .new_loan': ->
            classroom_id = Router.current().params.doc_id
            new_loan_id = Docs.insert
                model:'loan'
                classroom_id: classroom_id
            Router.go "/classroom/#{classroom_id}/loan/#{new_loan_id}/edit"



    Template.loan_stats.events
        'click .refresh_loan_stats': ->
            Meteor.call 'refresh_loan_stats', @_id




if Meteor.isServer
    Meteor.publish 'loans', (product_id)->
        Docs.find
            model:'loan'
            product_id:product_id

    Meteor.methods
        refresh_loan_stats: (loan_id)->
            loan = Docs.findOne loan_id
            # console.log loan
            reservations = Docs.find({model:'reservation', loan_id:loan_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_loan_hours = 0
            average_loan_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_loan_hours += parseFloat(res.hour_duration)

            average_loan_cost = total_earnings/reservation_count
            average_loan_duration = total_loan_hours/reservation_count

            Docs.update loan_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_loan_hours: total_loan_hours.toFixed(0)
                    average_loan_cost: average_loan_cost.toFixed(0)
                    average_loan_duration: average_loan_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header loan ranking #reservations
            # .ui.small.header loan ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg loan time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
