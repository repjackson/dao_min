Meteor.methods
    pull_tag: (tag)->
        tag_doc_count =
            Docs.find(tags:$in:[tag]).count()
        console.log 'tag doc count', tag_doc_count
        Docs.update({tags:$in:[tag]}, {$pull:tags:tag}, {multi:true})

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
