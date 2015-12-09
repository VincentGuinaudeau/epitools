EpitoolsStatusView = require './epitools-status-view'
{CompositeDisposable} = require 'atom'

module.exports = Epitools =
    epitoolsStatusView: null
    subscriptions: null

    activate: (@state) ->
        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        # Register command that toggles this view
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:toggle': => @toggle()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:toggle-activation': => @toggle_activation()

    consumeStatusBar: (statusBar) ->
        console.log 'status-bar'
        @epitoolsStatusView = new EpitoolsStatusView(@state.epitoolsStatusViewState, statusBar)

    deactivate: ->
        @subscriptions.dispose()
        @statusBarTile.destroy()
        @epitoolsStatusView.destroy()

    serialize: ->
        epitoolsStatusViewState: @epitoolsStatusView.serialize()

    toggle: ->
        console.log 'Epitools was toggled!'
        if @epitoolsStatusView.visible
            @epitoolsStatusView.hide()
        else
            @epitoolsStatusView.show()

    toggle_activation: ->
        console.log 'Epitools was activated!'
        if @epitoolsStatusView.active
            @epitoolsStatusView.turn_off()
        else
            @epitoolsStatusView.turn_on()
