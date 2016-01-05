{CompositeDisposable, TextEditor, Range} = require 'atom'
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
        headersFormat.headerRange = new Range [0, 0], [headersFormat.text.length + 2, 0]

        console.log headersFormat.headerRange

        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-top': => @insertHeaderTop()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-cursor': => @insertHeaderCursor()

        for scope of headersFormat.scopes
            headersFormat.scopes[scope].regex = new RegExp '^' + @generateHeader scope, '', true

        # update header on save and prevent modification
        atom.workspace.observeTextEditors (editor) =>
            self = this
            buffer = editor.getBuffer()
            func = ->
                return if self.bufferMap.has buffer
                disposable = null
                self.bufferMap.set buffer,
                    will: buffer.onWillSave ->
                        scope = self.extractHeaderType buffer
                        return if not scope
                        header = self.generateHeader scope, ''
                        header = header.split '\n'
                        # console.log buffer.getText()
                        # console.log editor
                        for line in headersFormat.updateLines
                            # console.log header[line]
                            buffer.setTextInRange [[line, 0], [line + 1, 0]], header[line] + '\n'
                        disposable = buffer.onDidChange (event) ->
                            console.log event
                            if event.oldRange.start.row <= headersFormat.headerRange.end.row &&
                            event.oldText is ' ' &&
                            event.newText is ''
                                buffer.setTextInRange event.newRange, event.oldText
                    did: buffer.onDidSave ->
                        if disposable
                            console.log 'did save'
                            disposable.dispose()
                            disposable = null
            func()

    deactivate: ->
        @subscriptions.dispose()

    refresh: ->

    isSupported: (scope) ->
        headersFormat.scopes[scope] && scope isnt 'default'

    extractHeaderType: (buffer) ->
        buffer = buffer.getTextInRange(headersFormat.headerRange)
        for scope of headersFormat.scopes
            if headersFormat.scopes[scope].regex.test buffer
                return scope
        return false

    hasHeader: (editor) ->
        buffer = editor.getTextInBufferRange(headersFormat.headerRange)
        regex = headersFormat.scopes[editor.getRootScopeDescriptor().scopes[0]].regex or headersFormat.scopes.default.regex
        regex.test buffer

    generateDate: ->
        date = new Date
        format = headersFormat.datesFormat
        format.replace /MM/g, headersFormat.monthNames[date.getMonth()]
            .replace /DD/g, date.getDate()
            .replace /YYYY/g, date.getFullYear()
            .replace /HH/g, date.getHours()
            .replace /MI/g, date.getMinutes()
            .replace /SS/g, date.getSeconds()

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
