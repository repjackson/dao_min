if Meteor.isClient
    Template.view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'schema', Router.current().params.doc_id



    Template.view.helpers
        sorted_matches: ->
            # console.log @
            sorted_matches = _.sortBy @matches, 'tag_match_count'
            sorted_matches.reverse()[..2]

    Template.view.events
        'click .calculate': ->
            Meteor.call 'related_posts', Router.current().params.doc_id

    # Template.related_posts.helpers
    #     related_posts: ->
    #         doc_id = Router.current().params.doc_id
    #         post = Docs.findOne doc_id
    #         if post.related_ids
    #             Docs.find
    #                 _id:$in:post.related_ids

    Template.doc_match.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data.doc_id

    Template.doc_match.events
        'click .doc_match': ->
            console.log @
            Router.go "/m/post/#{@doc_id}/view"


    Template.doc_match.helpers
        matching_doc: ->
            # console.log @
            Docs.findOne @doc_id

        matching_tag_class: ->
            post = Docs.findOne Router.current().params.doc_id
            if @valueOf() in post.tags then 'grey' else 'basic'
            # console.log @


if Meteor.isServer
    Meteor.methods
        related_posts: (doc_id)->
            post = Docs.findOne doc_id
            unless post.matches
                Docs.update doc_id,
                    $set:matches:[]
            related_ids = []

            matches = post.matches
            related_posts_with_counts = []
            # console.log 'finding matches for ', post
            for tag in post.tags
                found_matches = Docs.find
                    _id:$ne:doc_id
                    tags:$in:[tag]
                if found_matches.fetch().length > 0
                    for found_match in found_matches.fetch()
                        related_ids.push found_match._id
                        match_subobject = _.where(matches, {doc_id: found_match._id})
                        # console.log 'match subobject', match_subobject
                        union = _.intersection(found_match.tags, post.tags)
                        if match_subobject.length > 0
                            Docs.update { _id:doc_id, "matches.doc_id":found_match._id},
                                $set: "matches.$.tag_match_count": union.length
                        else
                            match_subobject = {doc_id:found_match._id,tag_match_count:union.length}
                            Docs.update _id:doc_id,
                                $addToSet: "matches": match_subobject

                # console.log 'found match with ', tag, found_matches.fetch()
            # console.log 'related ids', related_ids
            Docs.update doc_id,
                $set:related_ids:related_ids



    Meteor.publish 'related_posts', (doc_id)->
        post = Docs.findOne doc_id
        if post.related_ids
            Docs.find
                _id:$in:post.related_ids
