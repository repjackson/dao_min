Meteor.methods
    clean_tags: ()->


    check_subreddit: (sub)->
        console.log 'checking subreddit', sub
        existing =
            Subreddits.findOne(title:sub)
        if existing
            console.log 'found sub', existing
            Meteor.call 'pull_subreddit', sub
        else
            console.log 'no existing sub found'
            HTTP.get("http://reddit.com/r/#{sub}.json", (err,res)=>
                if err
                    console.log "no sub found error", sub
                else
                    Subreddits.insert
                        title:sub
                    console.log 'success, added sub to list', sub
                    Meteor.call 'pull_subreddit', sub

            )
        # return response.content


    pull_tag: (tag)->
        tag_doc_count =
            Docs.find(tags:$in:[tag]).count()
        console.log 'tag doc count', tag_doc_count
        Docs.update({tags:$in:[tag]}, {$pull:tags:tag}, {multi:true})

    remove_subreddit: (subreddit)->
        Docs.remove({subreddit:subreddit})

    import_site: (site)->
        existing_doc = Docs.findOne url:site
        if existing_doc
            console.log 'found existing doc', existing_doc
        else
            new_doc_id = Docs.insert
                url: site
            Meteor.call 'call_watson', new_doc_id, 'url', 'url'

    delete_docs_tag: (tag)->
        tag_doc_count =
            Docs.find(tags:$in:[tag]).count()
        console.log 'tag doc count', tag_doc_count
        Docs.remove({tags:$in:[tag]})

    add_tag: (doc_id, tag)->
        Docs.update doc_id,
            $addToSet:tags:tag

    remove_tag: (doc_id, tag)->
        Docs.update doc_id,
            $pull: tags: tag

    calc_tag_count: (doc_id)->
        if doc_id
            doc = Docs.findOne doc_id
            if doc.tags
                doc_tag_count = doc.tags.length
                Docs.update doc_id,
                    $set:tag_count:doc_tag_count
                console.log 'updated doc', doc.title, 'with', doc_tag_count, 'tags'
        else
            uncounted_count = Docs.find({
                tag_count:$exists:false
                skip_watson: $ne:true
                }).count()
            console.log uncounted_count, 'uncounted docs'
            uncounted = Docs.find({
                tag_count:$exists:false
                skip_watson: $ne:true
            }, {limit:1000})
            for doc in uncounted.fetch()
                if doc.skip_watson
                    console.log 'skipping flagged doc', doc.title
                if doc.tags
                    doc_tag_count = doc.tags.length
                    Docs.update doc._id,
                        $set:tag_count:doc_tag_count
                    # console.log doc_tag_count
                    # console.log "updated doc '#{doc.title}' with #{doc_tag_count} tags"
                else
                    console.log 'no tags', doc.title, 'checking for image'
                    image_check = /(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)/
                    image_result = image_check.test doc.url
                    if image_result
                        # console.log 'found image'
                        Docs.remove doc._id
                        console.log 'deleted doc with image', doc.title, doc.url
                    else
                        console.log 'found non image, sending to watson', doc.url
                        console.log 'domain', doc.domain, 'calling watson'
                        Meteor.call 'call_watson', doc._id, 'url', 'url'

            console.log 'done counting tags'



    tag_untagged: ->
        untagged = Docs.find({tags:$exists:false}, {limit:3})
        # console.log untagged.count()
        for doc in untagged.fetch()
            image_check = /(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)/
            image_result = image_check.test doc.url
            if image_result
                Docs.remove doc._id
                if Meteor.isDevelopment
                    console.log 'found image'
                    console.log 'deleted doc with image', doc.title, doc.url
            else
                console.log 'found non image', doc.url
                # console.log doc
                # Meteor.call 'call_watson', doc._id, 'url', 'url'
