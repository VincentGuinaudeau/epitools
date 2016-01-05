{CompositeDisposable} = require 'atom'

module.exports =
class EpitoolsIndentation
    subscriptions = null

    activate: (state, @core) ->

    deactivate: ->

    refresh: ->
        if @subscriptions
            @subscriptions.dispose()
            @subscriptions = null
        console.log 'indentaion', @core.currentEditor.active
        return if not @core.currentEditor.active
        @subscriptions = new CompositeDisposable
        editor = @core.currentEditor.editor
        console.log 'active'
        @subscriptions.add editor.onWillInsertText (event) ->
            # console.log event
        @subscriptions.add editor.getBuffer().onWillChange (event) ->
            # console.log event
