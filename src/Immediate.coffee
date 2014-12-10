if !window.setImmediate or typeof window.setImmediate isnt 'function'
  define(
    ->
      window.setImmediate or (->
        uid = 0
        storage = {}
        firstCall = true
        slice = Array::slice
        message = "setImmediatePolyfillMessage"
        fastApply = (args) ->
          func = args[0]
          switch args.length
            when 1
              return func()
            when 2
              return func(args[1])
            when 3
              return func(args[1], args[2])
          func.apply window, slice.call(args, 1)
        callback = (event) ->
          key = event.data
          data = undefined
          if "string" is typeof key and 0 is key.indexOf(message)
            data = storage[key]
            if data
              delete storage[key]

              fastApply data
          return
        window.setImmediate = setImmediate = ->
          id = uid++
          key = message + id
          storage[key] = arguments
          if firstCall
            firstCall = false
            window.addEventListener "message", callback
          window.postMessage key, "*"
          id

        window.clearImmediate = clearImmediate = (id) ->
          delete storage[message + id]
          return
        setImmediate
      )()
  )
else
  define(
    ->
      setImmediate
  )