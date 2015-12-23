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
    currentEditor:
        editor: null
        disposable: null
        available: null
        active: null
    editorMap: null

    activate: (@state) ->
        @editorMap = new WeakMap
        @deserialize()

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        @subscriptions.add atom.workspace.onDidChangeActivePaneItem @changeEditor.bind(this)
        @changeEditor atom.workspace.getActivePaneItem()

        # Register command
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:toggle-available': => @toggleAvailable()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:toggle-activation': => @toggleActivation()

        # init modules
        for i in EpitoolsModules
            i.activate @state[i], this

    consumeStatusBar: (statusBar) ->
        @epitoolsStatusViewState = new EpitoolsStatusView @state.epitoolsStatusViewState, statusBar
        @epitoolsStatusViewState.set_visible @currentEditor.available
        @epitoolsStatusViewState.set_active @currentEditor.active

    isValid: (editor) ->
        editor instanceof TextEditor

    setMap: (editor, attribute, value) ->
        obj = @editorMap.get editor
        obj[attribute] = value

    # initEditor: (editor) ->
    #     @currentEditor.available = @detectGrammar editor
    #     @currentEditor.active = if @currentEditor.available then @isTurnOn editor else false
    #     @editorMap.set editor,
    #         available: @currentEditor.available
    #         active: @currentEditor.active

    updateEditor: (grammar) ->
        if @editorMap.has editor
            {available, active} = @editorMap.get editor
            @currentEditor.available = available
            @currentEditor.active = active
        else
            @currentEditor.available = @detectGrammar editor
            @currentEditor.active = if @currentEditor.available then @isTurnOn editor else false
            @editorMap.set editor,
                available: @currentEditor.available
                active: @currentEditor.active
        @epitoolsStatusViewState?.set_visible @currentEditor.available
        @epitoolsStatusViewState?.set_active @currentEditor.active
        for i in EpitoolsModules
            i.changeEditor editor if i.changeEditor

    changeEditor: (editor) ->
        @currentEditor.disposable.dispose()
        if @isValid editor
            @currentEditor.editor = editor
            @currentEditor.disposable = editor.observeGrammar @updateEditor
            console.log 'event set'
        else
            @currentEditor.available = false
            @currentEditor.active = false
        # if @isValid editor
        #     if @editorMap.has editor
        #         {available, active} = @editorMap.get editor
        #         @currentEditor.available = available
        #         @currentEditor.active = active
        #     else
        #         @currentEditor.available = @detectGrammar editor
        #         @currentEditor.active = if @currentEditor.available then @isTurnOn editor else false
        #         @editorMap.set editor,
        #             available: @currentEditor.available
        #             active: @currentEditor.active
        # else
        #     @currentEditor.available = false
        #     @currentEditor.active = false
        # @epitoolsStatusViewState?.set_visible @currentEditor.available
        # @epitoolsStatusViewState?.set_active @currentEditor.active
        # for i in EpitoolsModules
        #     i.changeEditor editor if i.changeEditor

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
        @epitoolsStatusViewState.set_active @currentEditor.available

    toggleActivation: (force_state = null) ->
        editor = atom.workspace.getActivePaneItem()
        return null if not @isValid editor
        if @currentEditor.available
            @currentEditor.active = if force_state is null then !@currentEditor.active else force_state
            @setMap editor, 'active', @isActive
            @epitoolsStatusViewState.set_active @currentEditor.active
