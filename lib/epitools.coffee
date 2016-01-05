EpitoolsStatusView = require './epitools-status-view'
EpitoolsModules =
    header: new (require './epitools-headers')()
{CompositeDisposable, TextEditor} = require 'atom'

module.exports =
    config: require './config.json'
    supportedGrammar: ['source.c', 'source.makefile']
    epitoolsStatusView: null
    subscriptions: null
    currentEditor:
        editor: null
        grammar: null
        disposable: null
        available: null
        active: null
    editorMap: null

    activate: (@state) ->
        @editorMap = new WeakMap
        @deserialize()

        # init modules
        for i of EpitoolsModules
            EpitoolsModules[i].activate @state[i], this

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        @subscriptions.add atom.workspace.onDidChangeActivePaneItem @changeEditor.bind(this)
        @changeEditor atom.workspace.getActivePaneItem()

        # Register command
        @subscriptions.add atom.commands.add 'atom-workspace',
            'epitools:toggle-available': => @toggleAvailable()
            'epitools:toggle-activation': => @toggleActivation()

    deactivate: ->
        @subscriptions.dispose()
        @statusBarTile.destroy()
        @epitoolsStatusView.destroy()

    consumeStatusBar: (statusBar) ->
        @epitoolsStatusViewState = new EpitoolsStatusView @state.epitoolsStatusViewState, statusBar
        @epitoolsStatusViewState.set_visible @currentEditor.available
        @epitoolsStatusViewState.set_active @currentEditor.active

    isValid: (editor) ->
        editor instanceof TextEditor

    setMap: (editor, attribute, value) ->
        obj = @editorMap.get editor
        obj[attribute] = value

    refresh: ->
        @epitoolsStatusViewState?.set_visible @currentEditor.available
        @epitoolsStatusViewState?.set_active @currentEditor.active
        for i of EpitoolsModules
            EpitoolsModules[i].refresh() if EpitoolsModules[i].refresh

    updateEditor: (grammar) ->
        editor = @currentEditor.editor
        scope = null
        if @editorMap.has editor
            {available, active, scope} = @editorMap.get editor
            @currentEditor.available = available
            @currentEditor.active = active
        if scope isnt grammar.scopeName
            @currentEditor.available = EpitoolsModules.header.isSupported grammar.scopeName
            @currentEditor.active = if @currentEditor.available then @isTurnOn editor else false
            @editorMap.set editor,
                available: @currentEditor.available
                active: @currentEditor.active
                scope: grammar.scopeName
        @refresh()

    changeEditor: (editor) ->
        @currentEditor.disposable?.dispose()
        if @isValid editor
            @currentEditor.editor = editor
            @currentEditor.disposable = editor.observeGrammar @updateEditor.bind(this)
        else
            @currentEditor =
                editor: null
                grammar: null
                disposable: null
                available: false
                active: false
            @refresh()

    isTurnOn: (editor) ->
        switch atom.config.get('epitools.autoActivation')
            when 'always' then return true
            when 'never' then return false
            when 'if header' then return EpitoolsModules.header.hasHeader editor

    serialize: ->
        available: @currentEditor.available
        active: @currentEditor.active
        epitoolsStatusViewState: @epitoolsStatusView.serialize()

    deserialize: ->
        @currentEditor.active = @state?.active
        @currentEditor.active = @state?.active

    toggleAvailable: (force_state = null) ->
        editor = atom.workspace.getActivePaneItem()
        return null if not @isValid editor
        @currentEditor.available = if force_state is null then !@currentEditor.available else force_state
        @setMap editor, 'available', @currentEditor.available
        @refreshk

    toggleActivation: (force_state = null) ->
        editor = atom.workspace.getActivePaneItem()
        return null if not @isValid editor
        if @currentEditor.available
            @currentEditor.active = if force_state is null then !@currentEditor.active else force_state
            @setMap editor, 'active', @isActive
            @refresh()
