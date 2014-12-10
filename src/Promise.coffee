if Promise
  define(
    ->
      unless typeof Promise::done is 'function'
        Promise::done = ->
          self = if arguments.length then @then.apply(@, arguments) else @
          self.then null, (err)->
            setTimeout(->
              throw err
            , 0)
      Promise
  )
else
  define(
    [
      './Immediate'
    ]
    (setImmediate)->
      toPromise = (thenable) ->
        return thenable  if isPromise(thenable)
        new Promise((resolve, reject) ->
          setImmediate ->
            try
              thenable.then resolve, reject
            catch error
              reject error
            return

          return
        )
      isCallable = (anything) ->
        "function" is typeof anything
      isPromise = (anything) ->
        anything instanceof Promise
      isThenable = (anything) ->
        Object(anything) is anything and isCallable(anything.then)
      isSettled = (promise) ->
        promise._fulfilled or promise._rejected
      identity = (value) ->
        value
      thrower = (reason) ->
        throw reason
        return
      call = (callback) ->
        callback()
        return
      dive = (thenable, onFulfilled, onRejected) ->
        interimOnFulfilled = (value) ->
          if isThenable(value)
            toPromise(value).then interimOnFulfilled, interimOnRejected
          else
            onFulfilled value
          return
        interimOnRejected = (reason) ->
          if isThenable(reason)
            toPromise(reason).then interimOnFulfilled, interimOnRejected
          else
            onRejected reason
          return
        toPromise(thenable).then interimOnFulfilled, interimOnRejected
        return
      Promise = (resolver) ->
        @_fulfilled = false
        @_rejected = false
        @_value = undefined
        @_reason = undefined
        @_onFulfilled = []
        @_onRejected = []
        @_resolve resolver
        return
      setImmediate = global.setImmediate or require("timers").setImmediate
      Promise.resolve = (value) ->
        return toPromise(value)  if isThenable(value)
        new Promise((resolve) ->
          resolve value
          return
        )

      Promise.reject = (reason) ->
        new Promise((resolve, reject) ->
          reject reason
          return
        )

      Promise.race = (values) ->
        new Promise((resolve, reject) ->
          value = undefined
          length = values.length
          i = 0
          while i < length
            value = values[i]
            if isThenable(value)
              dive value, resolve, reject
            else
              resolve value
            i++
          return
        )

      Promise.all = (values) ->
        new Promise((resolve, reject) ->
          thenables = 0
          fulfilled = 0
          value = undefined
          length = values.length
          i = 0
          values = values.slice(0)
          while i < length
            value = values[i]
            if isThenable(value)
              thenables++
              dive(
                value,
                ((index) ->
                  (value) ->
                    values[index] = value
                    fulfilled++
                    resolve values  if fulfilled is thenables
                    return
                )(i),
                reject
              )
            else

              #[1, , 3] → [1, undefined, 3]
              values[i] = value
            i++
          resolve values  unless thenables
          return
        )

      Promise:: =
        constructor: Promise
        _resolve: (resolver) ->
          resolve = (value) ->
            promise._fulfill value
            return
          reject = (reason) ->
            promise._reject reason
            return
          promise = this
          try
            resolver resolve, reject
          catch error
            reject error  unless isSettled(promise)
          return

        _fulfill: (value) ->
          unless isSettled(this)
            @_fulfilled = true
            @_value = value
            @_onFulfilled.forEach call
            @_clearQueue()
          return

        _reject: (reason) ->
          unless isSettled(this)
            @_rejected = true
            @_reason = reason
            @_onRejected.forEach call
            @_clearQueue()
          return

        _enqueue: (onFulfilled, onRejected) ->
          @_onFulfilled.push onFulfilled
          @_onRejected.push onRejected
          return

        _clearQueue: ->
          @_onFulfilled = []
          @_onRejected = []
          return

        then: (onFulfilled, onRejected) ->
          promise = this
          onFulfilled = (if isCallable(onFulfilled) then onFulfilled else identity)
          onRejected = (if isCallable(onRejected) then onRejected else thrower)
          new Promise((resolve, reject) ->
            asyncOnFulfilled = ->
              setImmediate ->
                value = undefined
                try
                  value = onFulfilled(promise._value)
                catch error
                  reject error
                  return
                if isThenable(value)
                  toPromise(value).then resolve, reject
                else
                  resolve value
                return

              return
            asyncOnRejected = ->
              setImmediate ->
                reason = undefined
                try
                  reason = onRejected(promise._reason)
                catch error
                  reject error
                  return
                if isThenable(reason)
                  toPromise(reason).then resolve, reject
                else
                  resolve reason
                return

              return
            if promise._fulfilled
              asyncOnFulfilled()
            else if promise._rejected
              asyncOnRejected()
            else
              promise._enqueue asyncOnFulfilled, asyncOnRejected
            return
          )

        catch: (onRejected) ->
          @then undefined, onRejected
        done: ->
          self = if arguments.length then @then.apply(@, arguments) else @
          self.then null, (err)->
            setTimeout(->
              throw err
            , 0)
      window.Promise = Promise
      Promise
  )