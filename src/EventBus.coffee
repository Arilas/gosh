define(
  [
    './Promise'
  ],
  (Promise)->
    class Event
      constructor: (@name, @data)->
        @propagated = yes
      stopPropagation: ->
        @propagated = no
    class EventManager
      constructor: ->
        @feed = {}
      subscribe: (event, handler)->
        @feed[event] = [] unless @feed[event]
        @feed[event].push handler
        @
      publish: (event, data)->
        return unless Array.isArray(@feed[event])
        promises = []
        @feed[event].forEach (callback)->
          if data
            promises.push new Promise (resolve, reject)-> callback data, resolve, reject
          else
            promises.push new Promise callback

        Promise.all promises
      trigger: (event, data)->
        return unless Array.isArray(@feed[event])
        promises = []
        e = new Event event, data
        @feed[event].forEach (callback)->
          if e.propagated
            promises.push new Promise (resolve, reject)-> callback e, resolve, reject
        Promise.all promises
      clear: (name)->
        if name
          @feed[name] = []
        else
          @feed = {}
        @

    EventBus = new EventManager()
    EventBus.EventManager = EventManager
    EventBus
)