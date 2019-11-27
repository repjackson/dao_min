Meteor.methods
    calc_question_stats: (question_id)->
        question = Docs.findOne question_id


Meteor.methods
    set_user_password: (user, password)->
        result = Accounts.setPassword(user._id, password)
        console.log result
        result

    create_user: (options)->
        console.log 'creating user', options
        Accounts.createUser options

    can_submit: ->
        username = Session.get 'username'
        password = Session.get 'password'
        if username
            if password.length > 0
                true
            else
                false

    find_username: (username)->
        res = Accounts.findUserByUsername(username)
        if res
            # console.log res
            unless res.disabled
                return res

    new_demo_user: ->
        current_user_count = Meteor.users.find().count()

        options = {
            username:"u#{current_user_count}"
            password:"u#{current_user_count}"
            }

        create = Accounts.createUser options
        new_user = Meteor.users.findOne create
        return new_user



    pull_tag: (tag)->
        tag_doc_count =
            Docs.find(tags:$in:[tag]).count()
        console.log 'tag doc count', tag_doc_count
        Docs.update({tags:$in:[tag]}, {$pull:tags:tag}, {multi:true})

    # remove_subreddit: (subreddit)->
    #     Docs.remove({subreddit:subreddit})

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
                # skip_watson: $ne:true
                }).count()
            console.log uncounted_count, 'uncounted docs'
            uncounted = Docs.find({
                tag_count:$exists:false
                # skip_watson: $ne:true
            }, {limit:10})
            for doc in uncounted.fetch()
                # if doc.skip_watson
                #     console.log 'skipping flagged doc', doc.title

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
