{CompositeDisposable} = require 'atom'

module.exports =
class EpitoolsIndentation

    activate: (state, @core) ->
        @subscriptions = new CompositeDisposable

    deactivate: ->

    refresh: ->
