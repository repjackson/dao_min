Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

Router.onBeforeAction(force_loggedin, {
  # only: ['admin']
  except: [
    'register'
    'login'
    'home'
    'page'
    'delta'
    'subs'
  ]
});

Router.route '*', -> @render 'not_found'

Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'

Router.route '/subs', (->
    @layout 'layout'
    @render 'subs'
    ), name:'subs'
