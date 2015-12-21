EpitoolsStatusView = require './epitools-status-view'
EpitoolsModules = [
    new (require './epitools-headers')()
]
{CompositeDisposable, TextEditor} = require 'atom'

module.exports =
    config:
        headers:
            type: 'object'
            properties:
                name:
                    type: 'string'
                    default: ''
                    description: 'format : Firstname Name'
                login:
                    type: 'string'
                    default: ''
                email:
                    type: 'string'
                    default: ''
    epitoolsStatusView: null
    subscriptions: null
    isAvailable: null
    isActive: null
    editorMap: null

    activate: (@state) ->
        @editorMap = new WeakMap
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
            i.activate @state[i], this

    consumeStatusBar: (statusBar) ->
        @epitoolsStatusViewState = new EpitoolsStatusView @state.epitoolsStatusViewState, statusBar
        @epitoolsStatusViewState.set_visible @available
        @epitoolsStatusViewState.set_active @active

    isValid: (editor) ->
        editor instanceof TextEditor

    setMap: (editor, attribute, value) ->
        obj = @editorMap.get editor
        obj[attribute] = value

    # active the package if the editor have a C grammar activate
    refresh: (editor) ->
        if @editorMap.has editor
            {isAvailable, isActive} = @editorMap.get editor
            @isAvailable = isAvailable
            @isActive = isActive
        else if @isValid editor
            @isAvailable = @detectGrammar editor
            @isActive = if @isAvailable then @isTurnOn editor else false
            @editorMap.set editor,
                isAvailable: @isAvailable
                isActive: @isActive
        else
            @isAvailable = false
            @isActive = false
        @epitoolsStatusViewState?.set_visible @isAvailable
        @epitoolsStatusViewState?.set_active @isActive
        for i in EpitoolsModules
            i.refresh editor, @isActive if i.refresh

    # return true if grammar is C or Makefile
    detectGrammar: (editor) ->
        @scope = editor.getRootScopeDescriptor().scopes[0]
        if ['source.c', 'source.makefile'].indexOf(@scope) isnt -1
            @scope
        else
            false

    isTurnOn: (editor) ->
        false # TODO : detect header, config

    deactivate: ->
        @subscriptions.dispose()
        @statusBarTile.destroy()
        @epitoolsStatusView.destroy()

    serialize: ->
        isAvailable: @isAvailable
        isActive: @isActive
        epitoolsStatusViewState: @epitoolsStatusView.serialize()

    deserialize: ->
        @isActive = @state?.isActive
        @isActive = @state?.isActive

    toggleAvailable: (force_state = null) ->
        editor = atom.workspace.getActivePaneItem()
        return null if not @isValid editor
        @isAvailable = if force_state is null then !@isAvailable else force_state
        @setMap editor, 'isAvailable', @isAvailable
        @epitoolsStatusViewState.set_active @isAvailable

    toggleActivation: (force_state = null) ->
        editor = atom.workspace.getActivePaneItem()
        return null if not @isValid editor
        if @isAvailable
            @isActive = if force_state is null then !@isActive else force_state
            @setMap editor, 'isActive', @isActive
            @epitoolsStatusViewState.set_active @isActive
