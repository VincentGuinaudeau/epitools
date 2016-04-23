{CompositeDisposable, TextEditor} = require 'atom'
path = require 'path'
headersFormat = require './headers-format.json'
Input = require './epitools-input-views'

module.exports =
class EpitoolsHeaders
    core: null
    inputView: null
    bufferMap: null

    activate: (state, @core) ->
        @subscriptions = new CompositeDisposable
        @bufferMap = new WeakMap
        @inputView = new Input 'Project Name'

        @core.supportedGrammar = Object.keys(headersFormat.scopes).filter((e) -> e != 'default')
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-top': => @insertHeaderTop()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-cursor': => @insertHeaderCursor()

        for scope of headersFormat.scopes
            headersFormat.scopes[scope].regex = new RegExp '^' + @generateHeader scope, '', true
        console.log headersFormat.scopes

        atom.workspace.observeTextEditors (editor) =>
            self = this
            buffer = editor.getBuffer()
            func = ->
                return if self.bufferMap.has buffer
                self.bufferMap.set buffer, buffer.onWillSave ->
                    scope = self.extractHeaderType buffer
                    console.log scope
                    return if not scope
                    header = self.generateHeader scope, ''
                    header = header.split '\n'
                    console.log buffer
                    for line in headersFormat.updateLines
                        buffer.setTextInRange [[line, 0], [line + 1, 0]], header[line] + '\n'
            func()

    extractHeaderType: (buffer) ->
        buffer = buffer.getTextInRange([[0, 0], [9, 0]])
        for scope of headersFormat.scopes
            if headersFormat.scopes[scope].regex.test buffer
                return scope
        return false

    deactivate: ->
        @subscriptions.dispose()

    refresh: ->

    hasHeader: (editor) ->
        buffer = editor.getTextInBufferRange([[0, 0], [9, 0]])
        regex = headersFormat.scopes[editor.getRootScopeDescriptor().scopes[0]].regex or headersFormat.scopes.default.regex
        regex.test buffer

    generateDate: ->
        date = new Date
        format = headersFormat.datesFormat
        format.replace /MM/g, headersFormat.monthNames[date.getMonth()]
            .replace /DN/g, headersFormat.monthNames[date.getDay()]
            .replace /DD/g, date.getDate()
            .replace /YYYY/g, date.getFullYear()
            .replace /HH/g, ('0' + date.getHours()).slice(-2)
            .replace /MI/g, ('0' + date.getMinutes()).slice(-2)
            .replace /SS/g, ('0' + date.getSeconds()).slice(-2)

    replaceInfo: (header, editor, project) ->
        if typeof editor is 'string'
            filePath = './'
        else
            filePath = editor.getBuffer().getPath()
        header.replace /\$FILE_NAME/g, path.basename filePath
            .replace /\$PATH/g, path.dirname filePath
            .replace /\$PROJECT/g, project
            .replace /\$USER_NAME/g, atom.config.get('epitools.headers.name') or ''
            .replace /\$USER_LOGIN/g, atom.config.get('epitools.headers.login') or ''
            .replace /\$USER_EMAIL/g, atom.config.get('epitools.headers.email') or ''
            .replace /\$DATE/g, @generateDate()

    generateHeader: (editor, project='', forRegex) ->
        if typeof editor is 'string'
            scope = editor
        else
            scope = editor.getRootScopeDescriptor().scopes[0]
        format = headersFormat.scopes[scope] or headersFormat.scopes.default
        str = format.head + '\n'
        for line in headersFormat.text
            str += format.body + ' ' + line + '\n'
        str += format.tail
        str += '\n' if not forRegex
        if forRegex
            str.replace(/[\*\\]/g, '\\$&').replace(/\$[A-Z_]*/g, '.*').replace(/() \n/g, ' ?\n')
        else
            @replaceInfo str, editor, project

    insertHeaderTop: ->
        self = this
        editor = atom.workspace.getActivePaneItem()
        return null if editor not instanceof TextEditor
        @inputView.setConfirm (input) ->
            header = self.generateHeader editor, input
            editor.setTextInBufferRange([[0, 0], [0, 0]], header)
            @detach()
            if self.core.currentEditor.available and atom.config.get('epitools.activateHeader')
                self.core.toggleActivation true
        @inputView.setInput @inputView.getText(), true
        @inputView.attach()

    insertHeaderCursor: ->
        self = this
        editor = atom.workspace.getActivePaneItem()
        return null if editor not instanceof TextEditor
        @inputView.setConfirm (input) ->
            header = self.generateHeader editor, input
            editor.mutateSelectedText (selection, index) ->
                if selection.getBufferRange().start.column == 0
                    selection.insertText header
                else
                    selection.insertText '\n' + header
            @detach()
        @inputView.setInput @inputView.getText(), true
        @inputView.attach()
