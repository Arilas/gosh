define(
  [
    './Router'
  ],
  (Router)->
    class Application
      router: undefined
      routeMatch: undefined
      constructor: ->
        @router = new Router()
      bootstrap: ->
        @routeMatch = @router.match location
)