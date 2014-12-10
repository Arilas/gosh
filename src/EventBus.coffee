define(
  [
    './Promise'
  ],
  (Promise)->
    EventBus =
      feed: {}
      subscribe: (event, callback)->
        unless EventBus.feed[event]
          EventBus.feed[event] = []
        index = EventBus.feed[event].push callback
        ->
          EventBus.unsubscribe event, index - 1
      publish: (event, data)->
        promises = []
        EventBus.feed[event].forEach (callback)->
          if data
            promises.push new Promise (resolve, reject)-> callback data, resolve, reject
          else
            promises.push new Promise callback

        Promise.all promises
      unsubscribe: (event, id)->
        EventBus.feed[event].splice id, 1
        EventBus
      clear: (event)->
        if event
          EventBus.feed[event] = []
        else
          EventBus.feed = {}
        EventBus
)