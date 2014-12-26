define(
  [
    './Router'
  ],
  (Router)->
    class Application
      controllers: undefined
      currentController: undefined
      router: undefined
      routeMatch: undefined
      constructor: (papams)->
        @controllers = {}
        @router = new Router()
        if papams.routes
          @router.routes = papams.routes
      bootstrap: ->
        @routeMatch = @router.match location
        if @routeMatch
          unless @controllers[@routeMatch.route.controller]
            @loadController @routeMatch.route.controller
          else
            @dispatchController @routeMatch.route.controller
      loadController: (name)->
        require [name], (controller)=>
          @controllers[name] = new controller
          @controllers[name].init()
          @dispatchController name
      dispatchController: (name)->
        if @currentController
          @currentController.hide()
        @currentController = @controllers[name]
        @currentController.dispatch()


)