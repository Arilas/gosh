define(
  [
    'jquery'
  ],
  ($)->
    vars = /(\[\w{0,}\])/g
    class FormModel
      constructor: (@domNode)->
        @parse()
      parse: ->
        @domNode[0].elements.forEach(
          (node)->
            if node.name
              if vars.test node.name
                match = node.name.match vars
                name = node.name.replace vars, ''
                curr = @[name] = {}
                match.forEach (value, index)->
                  if index is match.length - 1
                    Object.defineProperty curr, value,
                      get: ->
                        node.value
                      set: (value)->
                        node.value = value
                  else
                    curr = curr[value] = {}
              else
                Object.defineProperty @, node.name,
                  get: ->
                    node.value
                  set: (value)->
                    node.value = value
          @
        )
)