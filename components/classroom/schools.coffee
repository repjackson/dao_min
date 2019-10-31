if Meteor.isClient
    Template.schools.onRendered ->
        # Session.setDefault 'view_mode', 'cards'
    Template.schools.helpers
        # viewing_cards: -> Session.equals 'view_mode', 'cards'
        # viewing_segments: -> Session.equals 'view_mode', 'segments'
    Template.schools.events
        # 'click .set_card_view': ->
        #     Session.set 'view_mode', 'cards'
        # 'click .set_segment_view': ->
        #     Session.set 'view_mode', 'segments'


    Template.schools.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'school'
    Template.schools.events
        'click .add_school': ->
            new_school = Docs.insert
                model:'school'
            Router.go "/school/#{new_school}/edit"


    Template.schools.helpers
        schools: ->
            Docs.find {
                model:'school'
            }, sort: _timestamp: -1
