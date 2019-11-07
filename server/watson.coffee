NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');

# console.log Meteor.settings.private.language.apikey
# console.log Meteor.settings.private.language.url
natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    iam_apikey: Meteor.settings.private.language.apikey
    url: Meteor.settings.private.language.url)



Meteor.methods
    call_watson: (doc_id, key, mode) ->
        self = @
        # console.log doc_id
        # console.log key
        # console.log mode
        doc = Docs.findOne doc_id
        if doc.skip_watson is true
            console.log 'skipping flagged doc', doc.title
        else
            parameters =
                concepts:
                    limit:20
                features:
                    entities:
                        emotion: false
                        sentiment: false
                        # limit: 2
                    keywords:
                        emotion: false
                        sentiment: false
                        # limit: 2
                    concepts: {}
                    categories: {}
                    # emotion: {}
                    # metadata: {}
                    # relations: {}
                    # semantic_roles: {}
                    # sentiment: {}

            switch mode
                when 'html'
                    parameters.html = doc["#{key}"]
                when 'text'
                    parameters.text = doc["#{key}"]
                when 'url'
                    parameters.url = doc["#{key}"]
                    parameters.return_analyzed_text = true
                    parameters.clean = true

            natural_language_understanding.analyze parameters, Meteor.bindEnvironment((err, response) ->
                if err
                    # console.log 'watson error for', parameters.url
                    # console.log err
                    Docs.update doc_id,
                        $set:skip_watson:true
                    console.log 'error, flaggged doc for future skip', parameters.url
                else
                    keyword_array = _.pluck(response.keywords, 'text')
                    lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()
                    # if Meteor.isDevelopment
                    #     console.log 'categories',response.categories
                    adding_tags = []
                    if response.categories
                        for category in response.categories
                            # console.log category.label.split('/')
                            for tag in category.label.split('/')
                                if tag.length > 0 then adding_tags.push tag
                    Docs.update { _id: doc_id },
                        $addToSet:
                            tags:$each:adding_tags

                    for entity in response.entities
                        # console.log entity.type, entity.text
                        if entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            #     console.log('quantity', entity.text)
                        else
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    # "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()

                    concept_array = _.pluck(response.concepts, 'text')
                    lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                    Docs.update { _id: doc_id },
                        $set:
                            body:response.analyzed_text
                            # watson: response
                    #         watson_concepts: lowered_concepts
                    #         watson_keywords: lowered_keywords
                            # doc_sentiment_score: response.sentiment.document.score
                            # doc_sentiment_label: response.sentiment.document.label
                    Docs.update { _id: doc_id },
                        $addToSet:
                            tags:$each:lowered_concepts
                    Docs.update { _id: doc_id },
                        $addToSet:
                            tags:$each:lowered_keywords
                    final_doc = Docs.findOne doc_id
                    # console.log 'all tags', final_doc.tags
                    if Meteor.isDevelopment
                        console.log 'final doc', final_doc.tags
            )
