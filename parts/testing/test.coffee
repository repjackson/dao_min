if Meteor.isClient
    Router.route '/tests', (->
        @layout 'layout'
        @render 'tests'
        ), name:'tests'
    Router.route '/test/:doc_id/edit', (->
        @layout 'layout'
        @render 'test_edit'
        ), name:'test_edit'
    Router.route '/test/:doc_id/view', (->
        @layout 'layout'
        @render 'test_view'
        ), name:'test_view'



    Template.test_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.test_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.test_edit.events
        'click .add_test_item': ->
            new_mi_id = Docs.insert
                model:'test_item'
            Router.go "/test/#{_id}/edit"


    Template.test_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.test_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
    Template.test_view.helpers
        sessions: ->
            Docs.find
                model:'test_session'
                test_id: Router.current().params.doc_id
    Template.test_view.events
        'click .add_question': ->
            new_question_id = Docs.insert
                model:'question'
                test_id:Router.current().params.doc_id
            Router.go "/question/#{new_question_id}/edit"

        'click .take_test': ->
            console.log @
            new_session_id = Docs.insert
                model:'test_session'
                test_id:Router.current().params.doc_id
            Router.go "/session/#{new_session_id}/"



    Template.tests.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'test'
    Template.tests.helpers
        tests: ->
            Docs.find
                model:'test'




    Template.tests_view_template.onRendered ->
        @autorun => Meteor.subscribe 'model_docs', 'test'
    Template.tests_view_template.helpers
        tests: ->
            Docs.find
                model:'test'
    Template.tests_view_template.events
        'click .take_test': ->
            console.log @




    Template.tests.events
        'click .add_test': ->
            new_test_id = Docs.insert
                model:'test'
            Router.go "/test/#{new_test_id}/edit"



    Template.test_stats.events
        'click .refresh_test_stats': ->
            Meteor.call 'refresh_test_stats', @_id




if Meteor.isServer
    Meteor.publish 'tests', (product_id)->
        Docs.find
            model:'test'
            product_id:product_id

    Meteor.methods
        refresh_test_stats: (test_id)->
            test = Docs.findOne test_id
            # console.log test
            reservations = Docs.find({model:'reservation', test_id:test_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_test_hours = 0
            average_test_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_test_hours += parseFloat(res.hour_duration)

            average_test_cost = total_earnings/reservation_count
            average_test_duration = total_test_hours/reservation_count

            Docs.update test_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_test_hours: total_test_hours.toFixed(0)
                    average_test_cost: average_test_cost.toFixed(0)
                    average_test_duration: average_test_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header test ranking #reservations
            # .ui.small.header test ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg test time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
