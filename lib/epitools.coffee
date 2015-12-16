EpitoolsStatusView = require './epitools-status-view'
EpitoolsModules = [
    new (require './epitools-headers')()
]
{CompositeDisposable} = require 'atom'

module.exports = Epitools =
    epitoolsStatusView: null
    subscriptions: null
    isAvailable: null
    isActive: null
    availableMap: null
    activeMap: null

    activate: (@state) ->
        @availableMap = new WeakMap
        @activeMap = new WeakMap
        @deserialize()

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        @subscriptions.add atom.workspace.onDidChangeActivePaneItem @refresh.bind(this)
        @refresh atom.workspace.getActivePaneItem()

        # Register command
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:toggle-available': => @toggleAvailable()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:toggle-activation': => @toggleActivation()

        # init modules
        for i in EpitoolsModules
            i.activate @subscriptions
        console.log EpitoolsModules

    consumeStatusBar: (statusBar) ->
        @epitoolsStatusViewState = new EpitoolsStatusView(@state.epitoolsStatusViewState, statusBar)
        @epitoolsStatusViewState.set_visible @available
        @epitoolsStatusViewState.set_active @active


    # active the package if the editor have a C grammar activate
    refresh: (editor) ->
        if @availableMap.has editor
            @isAvailable = @availableMap.get editor
            @isActive = @activeMap.get editor
        else
            @isAvailable = @detectGrammar editor
            @availableMap.set editor, @isAvailable
            @isActive = if @isAvailable then @isTurnOn editor else false
            @activeMap.set editor, @isActive
        @epitoolsStatusViewState?.set_visible @isAvailable
        @epitoolsStatusViewState?.set_active @isActive
        for i in EpitoolsModules
            i.refresh editor, @isActive if i.refresh

    # return true if grammar is C or Makefile
    detectGrammar: (editor) ->
        if editor.id # TODO : propely detect if it's a TextEditor
            @scope = editor.getRootScopeDescriptor().scopes[0]
            if ['source.c', 'source.makefile'].indexOf(@scope) isnt -1
                return @scope
        @scope = ''
        false

    isTurnOn: (editor) ->
        false # TODO : detect header, config

    deactivate: ->
        @subscriptions.dispose()
        @statusBarTile.destroy()
        @epitoolsStatusView.destroy()

    serialize: ->
        isActive: @isActive
        isActive: @isActive
        epitoolsStatusViewState: @epitoolsStatusView.serialize()

    deserialize: ->
        @isActive = @state?.isActive
        @isActive = @state?.isActive

    toggleAvailable: (force_state = null) ->
        @isAvailable = if force_state is null then !@isAvailable else force_state
        @availableMap.set atom.workspace.getActivePaneItem(), @isAvailable
        @epitoolsStatusViewState.set_active @isAvailable

    toggleActivation: (force_state = null) ->
        if @isAvailable
            @isActive = if force_state is null then !@isActive else force_state
            @activeMap.set atom.workspace.getActivePaneItem(), @isActive
            @epitoolsStatusViewState.set_active @isActive
