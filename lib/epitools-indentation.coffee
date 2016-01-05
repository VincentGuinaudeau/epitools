{CompositeDisposable} = require 'atom'

module.exports =
class EpitoolsIndentation

    activate: (state, @core) ->

    deactivate: ->

    refresh: ->
        return if not @core.currentEditor.activate
        if @subscriptions
            @subscriptions.dispose()
        @subscriptions = new CompositeDisposable
