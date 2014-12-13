define(
  ->
    LITERAL = 'literal'
    SEGMENT = 'segment'
    class Router
      # it's must be global for page
      routes: {}
      routeMatch: undefined
      match: (location)->
        for own name,route of @routes
          if route.type is LITERAL and location.pathname is route.path
            @routeMatch =
              name: name
              route: route
              match: []
          else if route.type is SEGMENT and @buildRegexp(route.path).test location.pathname
            @routeMatch =
              name: name
              route: route
              match: location.pathname.match @buildRegexp(route.path)
        @routeMatch
      buildRegexp: ->


    Router.LITERAL = LITERAL
    Router.SEGMENT = SEGMENT
    Router
)