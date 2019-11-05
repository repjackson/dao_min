if Meteor.isClient
    Template.home.onRendered ->
        Meteor.setTimeout ->
            # $('.dropdown').dropdown(
            #     on:'click'
            # )
            $('.ui.dropdown').dropdown(
                clearable:true
                action: 'activate'
                onChange: (text,value,$selectedItem)->
                    )
        , 1000

        Meteor.setTimeout ->
            $('.item').popup(
                preserve:true;
                hoverable:false;
            )
        , 1000

    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'my_classrooms'
        @autorun -> Meteor.subscribe 'model_docs','alert'
        # @autorun -> Meteor.subscribe 'role_models'
        @autorun => Meteor.subscribe 'global_settings'

        # @autorun -> Meteor.subscribe 'current_session'
        # @autorun -> Meteor.subscribe 'unread_messages'

    Template.home.helpers
        user_nav_button_class: ->
            if Meteor.user().handling_active
                'green'
            else
                ''
        alerts: ->
            Docs.find
                model:'alert'
        unread_alert_count: ->
            Docs.find(
                model:'alert'
                target_username: Meteor.user().username
                read_ids: $nin: [Meteor.userId()]
            ).count()

        role_models: ->
            if Meteor.user()
                if Meteor.user() and Meteor.user().roles
                    if 'dev' in Meteor.user().roles
                        Docs.find {
                            model:'model'
                        }, sort:title:1
                    else
                        Docs.find {
                            model:'model'
                            view_roles:$in:Meteor.user().roles
                        }, sort:title:1
            else
                Docs.find {
                    model:'model'
                    view_roles: $in:['public']
                }, sort:title:1

        models: ->
            Docs.find
                model:'model'

        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'cart_item'
                _author_id:Meteor.userId()
            }).count()

        mail_icon_class: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()
            if unread_count then 'red' else ''


        bookmarked_models: ->
            if Meteor.userId()
                Docs.find
                    model:'model'
                    bookmark_ids:$in:[Meteor.userId()]

        my_classrooms: ->
            if Meteor.userId()
                Docs.find
                    model:'classroom'
                    teacher_id:Meteor.userId()


    Template.home.events
        # 'mouseenter .item': (e,t)->
            # $(e.currentTarget).closest('.item').transition('pulse', 400)
        'click .menu_dropdown': ->
            $('.menu_dropdown').dropdown(
                on:'hover'
            )

        # 'click .item': (e,t)->
        #     $(e.currentTarget).closest('.item').transition(
        #         animation: 'pulse'
        #         duration: 100
        #     )


        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'

        'click .set_models': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'model', ->
                Session.set 'loading', false

        'click .set_model': ->
            Session.set 'loading', true
            # Meteor.call 'increment_view', @_id, ->
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false

        'click .set_reference': ->
            Session.set 'loading', true
            # Meteor.call 'increment_view', @_id, ->
            Meteor.call 'set_facets', 'reference', ->
                Session.set 'loading', false

        'click .spinning': ->
            Session.set 'loading', false









if Meteor.isServer
    Meteor.publish 'my_alerts', ->
        Docs.find
            model:'alert'
            user_id: Meteor.userId()

    Meteor.publish 'my_classrooms', ->
        Docs.find
            model:'classroom'
            teacher_id: Meteor.userId()

    Meteor.publish 'my_latest_activity', ->
        Docs.find {
            model:'log_event'
            _author_id: Meteor.userId()
        },
            limit:5
            sort:_timestamp:-1


    Meteor.publish 'bookmarked_models', ->
        if Meteor.userId()
            Docs.find
                model:'model'
                bookmark_ids:$in:[Meteor.userId()]


    Meteor.publish 'my_cart', ->
        if Meteor.userId()
            Docs.find
                model:'cart_item'
                _author_id:Meteor.userId()

    Meteor.publish 'unread_messages', (username)->
        if Meteor.userId()
            Docs.find {
                model:'message'
                to_username:username
                read_ids:$nin:[Meteor.userId()]
            }, sort:_timestamp:-1


    Meteor.publish 'me', ->
        Meteor.users.find @userId
