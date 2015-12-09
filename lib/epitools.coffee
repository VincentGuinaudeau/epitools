EpitoolsView = require './epitools-status-view'
{CompositeDisposable} = require 'atom'

module.exports = Epitools =
    epitoolsView: null
    subscriptions: null

    activate: (@state) ->
        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        # Register command that toggles this view
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:toggle': => @toggle()

    consumeStatusBar: (statusBar) ->
        console.log 'status-bar'
        @epitoolsView = new EpitoolsView(@state.epitoolsViewState, statusBar)

    deactivate: ->
        @subscriptions.dispose()
        @statusBarTile.destroy()
        @epitoolsView.destroy()

    serialize: ->
        epitoolsViewState: @epitoolsView.serialize()

    toggle: ->
        console.log 'Epitools was toggled!'

        if @epitoolsView.visible
            @epitoolsView.hide()
        else
            @epitoolsView.show()
