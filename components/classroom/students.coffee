if Meteor.isClient
    Template.student_item.onCreated ->
        @autorun => Meteor.subscribe 'user_by_id', @data
    Template.student_item.helpers
        student: -> Meteor.users.findOne Template.currentData()

    Template.student_selector.onCreated ->
        @student_results = new ReactiveVar
        @autorun => Meteor.subscribe 'student_ids', Router.current().params.doc_id
    Template.student_selector.helpers
        student_results: -> Template.instance().student_results.get()
        selected_students: ->
            student = Docs.findOne Router.current().params.doc_id
            Meteor.users.find
                _id:$in:student.student_ids
    Template.student_selector.events
        'click .clear_results': (e,t)->
            t.student_results.set null
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            if e.which is 13
                Meteor.call 'add_student', first_name, last_name, Router.current().params.doc_id, (err,res)=>
                    if err
                        console.log err
                    else
                        Docs.update Router.current().params.doc_id,
                            $addToSet:student_ids:res
                        $('#first_name').val('')
                        $('#last_name').val('')
        'keyup #student_input': (e,t)->
            search_value = $(e.currentTarget).closest('#student_input').val().trim()
            if e.which is 8
                t.student_results.set null
            else if search_value and search_value.length > 1
                Meteor.call 'lookup_student', search_value, (err,res)=>
                    if err then console.error err
                    else
                        t.student_results.set res
        'click .select_student': (e,t) ->
            page_doc = Docs.findOne Router.current().params.doc_id
            Docs.update Router.current().params.doc_id,
                $addToSet:student_ids:@_id
            t.student_results.set null
            $('#student_input').val ''
            # Docs.update page_doc._id,
            #     $set: assignment_timestamp:Date.now()

        'click .remove_student': ->
            if confirm "remove #{first_name} #{last_name} from student?"
                student = Docs.findOne Router.current().params.doc_id
                Docs.update student._id,
                    $pull:student_ids:@_id


if Meteor.isServer
    Meteor.publish 'student_ids', (classroom_id)->
        classroom = Docs.findOne classroom_id
        Meteor.users.find
            _id:$in:classroom.student_ids

    Meteor.publish 'user_by_id', (user_id)->
        Meteor.users.find user_id

    Meteor.methods
        lookup_student: (username_query)->
            console.log 'searching for ', username_query
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # roles:$in:['students']
                },{limit:10}).fetch()
