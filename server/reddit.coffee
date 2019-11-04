Meteor.methods
    pull_subreddit: (subreddit)->
        response = HTTP.get("http://reddit.com/r/#{subreddit}.json")
        # return response.content

        _.each(response.data.data.children, (item)->
            data = item.data
            len = 200
            # console.log item.data
            reddit_post =
                reddit_id: data.id
                url: data.url
                domain: data.domain
                comment_count: data.num_comments
                permalink: data.permalink
                title: data.title
                # selftext: false
                # thumbnail: false
                model:'reddit'

            # # console.log reddit_post
            existing_doc = Docs.findOne url:data.url
            if existing_doc
                console.log 'skipping existing url', data.url
                console.log 'existing doc', existing_doc
                # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
            unless existing_doc
                # console.log 'importing url', data.url
                new_reddit_post_id = Docs.insert reddit_post
                Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                    # console.log 'get post res', res
        )

    get_reddit_post: (doc_id, reddit_id)->
        HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
            if err then console.error err
            else
                if res.data.data.children[0].data.selftext
                    console.log "self text", res.data.data.children[0].data.selftext
                    # Docs.update doc_id, {
                    #     $set: html: res.data.data.children[0].data.selftext
                    # }, ->
                    #     Meteor.call 'pull_site', doc_id, url
                        # console.log 'hi'
                if res.data.data.children[0].data.url
                    url = res.data.data.children[0].data.url
                    console.log "found url", url
                    Docs.update doc_id, {
                        $set:
                            reddit_url: url
                            url: url
                    }, ->
                        Meteor.call 'call_watson', doc_id, 'url', 'url'
                Docs.update doc_id,
                    $set: reddit_data: res.data.data.children[0].data

    get_reddit_user: (rusername)->
        HTTP.get "http://reddit.com/user/#{rusername}/about.json", (err,res)->
            if err then console.error err
            else
                console.log res.data.data
                ruser = Docs.findOne
                    model:'ruser'
                    rusername:rusername
                unless ruser
                    new_ruser_id = Docs.insert
                        model:'ruser'
                        rusername:rusername
                    ruser = Docs.findOne new_ruser_id
                Docs.update ruser._id,
                    $set: reddit_data: res.data.data
                # if res.data.data.children[0].data.selftext
                #     console.log "self text", res.data.data.children[0].data.selftext
                #     # Docs.update doc_id, {
                #     #     $set: html: res.data.data.children[0].data.selftext
                #     # }, ->
                #     #     Meteor.call 'pull_site', doc_id, url
                #         # console.log 'hi'
                # if res.data.data.children[0].data.url
                #     url = res.data.data.children[0].data.url
                #     console.log "found url", url
                #     Docs.update doc_id, {
                #         $set:
                #             reddit_url: url
                #             url: url
                #     }, ->
                #         Meteor.call 'call_watson', doc_id, 'url', 'url'
                # Docs.update doc_id,
                #     $set: reddit_data: res.data.data.children[0].data


    get_listing_comments: (doc_id, subreddit, reddit_id)->
        console.log doc_id
        console.log subreddit
        console.log reddit_id
        # HTTP.get "https://www.reddit.com/r/t5_#{subreddit}/comments/t3_#{reddit_id}/irrelevant_string.json", (err,res)->
        HTTP.get "https://www.reddit.com/r/0xProject/comments/t3_#{reddit_id}/irrelevant_string.json", (err,res)->
            if err then console.error err
            else
                console.log 'res', res
