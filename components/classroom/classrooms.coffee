if Meteor.isClient
    Template.classrooms.onRendered ->
    Template.classrooms.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'classroom'
        @autorun => Meteor.subscribe 'users'
        @autorun -> Meteor.subscribe('classroom_facet_docs',
            selected_classroom_tags.array()
            Session.get('selected_school_id')
            # Session.get('sort_key')
        )

    Template.classrooms.events
        'click .add_classroom': ->
            new_classroom = Docs.insert
                model:'classroom'
                teacher_id: Meteor.userId()
            Router.go "/classroom/#{new_classroom}/edit"
    Template.classrooms.helpers
        classrooms: ->
            Docs.find {
                model:'classroom'
            }, sort: _timestamp: -1


    Template.classroom_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'classroom_stats'
    Template.classrooms.helpers



if Meteor.isServer
    Meteor.publish 'classrooms', ->
        Docs.find
            model:'classroom'
            teacher_id:Meteor.userId()
