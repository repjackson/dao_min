if Meteor.isClient
    Router.route '/school/:doc_id/edit', (->
        @layout 'school_edit_layout'
        @render 'school_edit_students'
        ), name:'school_edit'
    Router.route '/school/:doc_id/edit/info', (->
        @layout 'school_edit_layout'
        @render 'school_edit_info'
        ), name:'school_edit_info'
    Router.route '/school/:doc_id/edit/settings', (->
        @layout 'school_edit_layout'
        @render 'school_edit_settings'
        ), name:'school_edit_settings'
    Router.route '/school/:doc_id/edit/students', (->
        @layout 'school_edit_layout'
        @render 'school_edit_students'
        ), name:'school_edit_students'

    Router.route '/school/:doc_id/edit/f/:feature_slug', (->
        @layout 'school_edit_layout'
        @render 'school_edit_feature'
        ), name:'school_edit_feature'
    Router.route '/school/:doc_id/edit/debits', (->
        @layout 'school_edit_layout'
        @render 'school_edit_debits'
        ), name:'school_edit_debits'
    Router.route '/school/:doc_id/edit/credits', (->
        @layout 'school_edit_layout'
        @render 'school_edit_credits'
        ), name:'school_edit_credits'
    Router.route '/school/:doc_id/edit/shop', (->
        @layout 'school_edit_layout'
        @render 'school_edit_shop'
        ), name:'school_edit_shop'
    Router.route '/school/:doc_id/edit/templates', (->
        @layout 'school_edit_layout'
        @render 'school_edit_templates'
        ), name:'school_edit_templates'
    Router.route '/school/:doc_id/edit/files', (->
        @layout 'school_edit_layout'
        @render 'school_edit_files'
        ), name:'school_edit_files'
    Router.route '/school/:doc_id/edit/features', (->
        @layout 'school_edit_layout'
        @render 'school_edit_features'
        ), name:'school_edit_features'


    # Template.school_edit_layout.onRendered ->
    Template.school_edit_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.school_edit_layout.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 750
    Template.school_edit_layout.helpers
        enabled_features: ->
            school = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'feature'
                _id: $in: school.enabled_feature_ids






    Template.school_edit_debits.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'credit_type'
        @autorun => Meteor.subscribe 'school_docs', 'debit_type', Router.current().params.doc_id

    Template.school_edit_credits.onCreated ->
        @autorun => Meteor.subscribe 'school_docs', 'credit_type', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        # Session.set 'permission', false


    Template.school_edit_settings.onCreated ->
        @autorun => Meteor.subscribe 'all_school_docs', Router.current().params.doc_id


    Template.school_edit_settings.events
        'click .remove_school': ->
            console.log @
            school_docs =
                Docs.find(
                    school_id: @_id
                )
            console.log school_docs
            if confirm "confirm delete school? this will delete #{school_docs.count()} school documents"
                for school_doc in school_docs.fetch()
                    Docs.remove school_doc._id
                    $('body').toast({
                        message: "#{school_doc.model} deleted"
                        class:'info'
                    })
                Docs.remove @_id
                Router.go '/schools'



    Template.transaction.onCreated ->
        @editing_transaction = new ReactiveVar false
    Template.transaction.helpers
        editing_transaction: -> Template.instance().editing_transaction.get()
    Template.transaction.events
        'click .remove_transaction': (e,t)->
            if confirm "remove #{@title}?"
                $(e.currentTarget).closest('.segment').transition('fade right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

        'click .save_transaction': (e,t)->
            t.editing_transaction.set false
        'click .edit_transaction': (e,t)->
            t.editing_transaction.set true




    Template.school_edit_templates.onRendered ->
    Template.school_edit_templates.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'transaction_template'
    Template.school_edit_templates.helpers
        transaction_templates: ->
            Docs.find
                model:'transaction_template'
        my_transaction_templates: ->
            Docs.find
                model:'transaction_template'
                _author_id: Meteor.userId()
        selected_template: -> Docs.findOne Session.get('selected_template_id')
        template_class: -> if Session.equals('selected_template_id',@_id) then 'active' else ''
    Template.school_edit_templates.events
        'click .generate_from_current': ->
            school = Docs.findOne Router.current().params.doc_id
            new_template_id = Docs.insert
                model:'transaction_template'
                title:school.school_name
                school_school_name: school.school_name
                school_id: Router.current().params.doc_id
            Session.set 'selected_template_id', new_template_id
        'click .select_template': -> Session.set 'selected_template_id', @_id
        'click .add_credit_type': ->
            new_credit_id = Docs.insert
                model:'credit_type'
                school_id: Router.current().params.doc_id



    Template.school_edit_features.onRendered ->
    Template.school_edit_features.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'feature'
    Template.school_edit_features.helpers
        school_monthly_bill: ->
            bill = 0
            school = Docs.findOne Router.current().params.doc_id
            enabled_features =
                Docs.find(
                    model:'feature'
                    _id: $in: school.enabled_feature_ids
                ).fetch()
            for feature in enabled_features
                bill += feature.monthly_price
            bill

        disabled_features: ->
            school = Docs.findOne Router.current().params.doc_id
            match = {model:'feature'}
            if school.enabled_feature_ids
                match._id = $nin: school.enabled_feature_ids
            Docs.find match
        enabled_features: ->
            school = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'feature'
                _id: $in: school.enabled_feature_ids
        selected_feature: -> Docs.findOne Session.get('selected_feature_id')
        feature_class: -> if Session.equals('selected_feature_id',@_id) then 'active' else ''
    Template.school_edit_features.events
        'click .select_feature': -> Session.set 'selected_feature_id', @_id
        'click .add_feature': ->
            new_feature_id = Docs.insert
                model:'feature'
            Session.set 'selected_feature_id', new_feature_id


    Template.feature.onCreated ->
        @editing_feature = new ReactiveVar false
    Template.feature.helpers
        editing_feature: -> Template.instance().editing_feature.get()
        enabled: ->
            school = Docs.findOne Router.current().params.doc_id
            if @_id in school.enabled_feature_ids then true else false
        feature_class: ->
            school = Docs.findOne Router.current().params.doc_id
            if @_id in school.enabled_feature_ids then 'green raised' else ''
    Template.feature.events
        'click .enable_feature': ->
            if @dependencies and @dependencies.length
                if confirm "#{@title} is dependent on #{@dependencies}, each will be installed, confirm?"
                    Docs.update Router.current().params.doc_id,
                        $addToSet: enabled_feature_ids: @_id
                    $('body').toast({
                        message: "#{@title} enabled"
                        class:'success'
                        # showProgress: 'bottom'
                    })
                    for dependent in @dependencies
                        feature = Docs.findOne({model:'feature', slug:dependent})
                        Docs.update Router.current().params.doc_id,
                            $addToSet: enabled_feature_ids: feature._id
                        $('body').toast({
                            message: "#{dependent} enabled"
                            class:'success'
                        })

            else
                Docs.update Router.current().params.doc_id,
                    $addToSet: enabled_feature_ids: @_id
                $('body').toast({
                    message: "#{@title} enabled"
                    class:'success'
                    # showProgress: 'bottom'
                })


        'click .disable_feature': ->
            Docs.update Router.current().params.doc_id,
                $pull: enabled_feature_ids: @_id
            $('body').toast({
                message: "#{@title} disabled"
                class:'info'
                # showProgress: 'bottom'
            })
        'click .save_feature': (e,t)->
            t.editing_feature.set false
        'click .edit_feature': (e,t)->
            t.editing_feature.set true





    Template.school_edit_feature.onRendered ->
    Template.school_edit_feature.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'feature_by_slug', Router.current().params.feature_slug
    Template.school_edit_feature.helpers
        current_feature: ->
            Docs.findOne
                model:'feature'
                slug:Router.current().params.feature_slug

        feature_edit_template: ->
            # console.log @
            "school_edit_#{@slug}"





    Template.template.onCreated ->
        @editing_template = new ReactiveVar false
        console.log @data
        @autorun => Meteor.subscribe 'school_docs', 'credit_type', @data.school_id
        @autorun => Meteor.subscribe 'school_docs', 'debit_type', @data.school_id
        @autorun => Meteor.subscribe 'model_docs', 'debit_type'
        @autorun => Meteor.subscribe 'model_docs', 'credit_type'

    Template.template.helpers
        editing_template: -> Template.instance().editing_template.get()
        school_debits: ->
            Docs.find
                model:'debit_type'
                template_id: $exists: false
                school_id: @school_id
        school_credits: ->
            Docs.find
                model:'credit_type'
                template_id: $exists: false
                school_id: @school_id
    Template.template.events
        'click .clone_template': ->
            # console.log @
            school_credits =
                Docs.find(
                    model:'credit_type'
                    school_id: @school_id
                    template_id: $exists: false
                ).fetch()
            for credit in school_credits
                # console.log 'cloning credit', credit
                new_credit_object = {}
                new_credit_object.model = 'credit_type'
                new_credit_object.school_id = Router.current().params.doc_id
                new_credit_object.template_id = @_id

                if credit.title
                    new_credit_object.title = credit.title
                if credit.amount
                    new_credit_object.amount = credit.amount
                if credit.description
                    new_credit_object.description = credit.description
                if credit.dispersion_type
                    new_credit_object.dispersion_type = credit.dispersion_type
                if credit.icon
                    new_credit_object.icon = credit.icon
                if credit.manual_limit_type
                    new_credit_object.manual_limit_type = credit.manual_limit_type
                if credit.manual_period
                    new_credit_object.manual_period = credit.manual_period
                if credit.scope
                    new_credit_object.scope = credit.scope
                Docs.insert new_credit_object
                $('body').toast({
                    message: "credit #{credit.title} was cloned"
                    class:'success'
                    # showProgress: 'bottom'
                })

            school_debits =
                Docs.find(
                    model:'debit_type'
                    school_id: @school_id
                    template_id: $exists: false
                ).fetch()
            for debit in school_debits
                # console.log 'cloning debit', debit
                new_debit_object = {}
                new_debit_object.model = 'debit_type'
                new_debit_object.school_id = Router.current().params.doc_id
                new_debit_object.template_id = @_id

                if debit.title
                    new_debit_object.title = debit.title
                if debit.amount
                    new_debit_object.amount = debit.amount
                if debit.description
                    new_debit_object.description = debit.description
                if debit.dispersion_type
                    new_debit_object.dispersion_type = debit.dispersion_type
                if debit.icon
                    new_debit_object.icon = debit.icon
                if debit.manual_limit_type
                    new_debit_object.manual_limit_type = debit.manual_limit_type
                if debit.manual_period
                    new_debit_object.manual_period = debit.manual_period
                if debit.scope
                    new_debit_object.scope = debit.scope
                Docs.insert new_debit_object
                $('body').toast({
                    message: "debit #{debit.title} was cloned"
                    class:'success'
                    # showProgress: 'bottom'
                })
            console.log school_debits
        'click .save_template': (e,t)->
            t.editing_template.set false
        'click .edit_template': (e,t)->
            t.editing_template.set true






if Meteor.isServer
    Meteor.publish 'feature_by_slug', (slug)->
        Docs.find
            model:'feature'
            slug:slug
