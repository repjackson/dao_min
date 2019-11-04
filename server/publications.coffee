Meteor.publish 'model_from_child_id', (child_id)->
    child = Docs.findOne child_id
    Docs.find
        model:'model'
        slug:child.type


Meteor.publish 'model_fields_from_child_id', (child_id)->
    child = Docs.findOne child_id
    model = Docs.findOne
        model:'model'
        slug:child.type
    Docs.find
        model:'field'
        parent_id:model._id

Meteor.publish 'model_docs', (model,limit)->
    if limit
        Docs.find {
            model: model
        }, limit:limit
    else
        Docs.find
            model: model

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (doc_id)->
    Docs.find
        parent_id:doc_id

Meteor.publish 'all_classroom_docs', (doc_id)->
    console.log 'running classroom docs', doc_id
    Docs.find
        classroom_id:doc_id


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug


Meteor.publish 'current_session', ->
    Docs.find
        model: 'healthclub_session'
        current:true


Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    Meteor.users.find user_id

Meteor.publish 'page', (slug)->
    Docs.find
        model:'page'
        slug:slug

Meteor.publish 'page_children', (slug)->
    page = Docs.findOne
        model:'page'
        slug:slug
    Docs.find
        parent_id:page._id



Meteor.publish 'checkin_guests', (doc_id)->
    session_document = Docs.findOne doc_id
        # model:'healthclub_session'
        # current:true
    Docs.find
        _id:$in:session_document.guest_ids


Meteor.publish 'student', (guest_id)->
    guest = Docs.findOne guest_id
    Meteor.users.find
        _id:guest.student_id



Meteor.publish 'health_club_students', (username_query)->
    existing_sessions =
        Docs.find(
            model:'healthclub_session'
            active:true
        ).fetch()
    active_session_ids = []
    for active_session in existing_sessions
        active_session_ids.push active_session.user_id
    Meteor.users.find({
        # _id:$nin:active_session_ids
        username: {$regex:"#{username_query}", $options: 'i'}
        # healthclub_checkedin:$ne:true
        roles:$in:['student','owner']
        },{ limit:20 })




Meteor.publish 'page_blocks', (slug)->
    page = Docs.findOne
        model:'page'
        slug:slug
    if page
        Docs.find
            parent_id:page._id


Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id