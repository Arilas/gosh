define(
  [
    'jquery'
  ],
  ->
    class Ceil
      constructor: (@domNode, @name, @prop)->
        @callbacks = []
      toString: ->
        @getValue()
      getValue: ->
        @domNode.prop @prop
      then: (callback)->
        @callbacks.push callback
        callback @getValue()
      val: (value)->
        @domNode.prop @prop, value
        @callbacks.forEach (callback)->
          callback value
    Ceil.add = (object, node, name, prop = 'value')->
      ceil = new Ceil node, name, prop
      Object.defineProperty object, name,
        get: -> ceil
        set: (value)->ceil.val value
    class Widget
      defineLift: (name, prop, node = @domNode)->
        Ceil.add @, node, name, prop
    Widget.Ceil = Ceil

    Widget
)