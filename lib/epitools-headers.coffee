{CompositeDisposable, TextEditor} = require 'atom'
path = require 'path'
headersFormat = require './headers-format.json'
Input = require './epitools-input-views'

module.exports =
class EpitoolsHeaders
    core: null
    inputView: null

    activate: (state, @core) ->
        @subscriptions = new CompositeDisposable

        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-top': => @insertHeaderTop()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-cursor': => @insertHeaderCursor()

        @inputView = new Input 'Project Name'
        # @inputView.setLabel 'Project name', 'icon-arrow-right'

    deactivate: ->
        @subscriptions.dispose()

    refresh: ->

    hasHeader: (editor) ->
        buffer = editor.getTextInBufferRange([[0, 0], [10, 0]])

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
        filePath = editor.getBuffer().getPath()
        header.replace /\$FILE_NAME/g, path.basename filePath
            .replace /\$PATH/g, path.dirname filePath
            .replace /\$PROJECT/g, project
            .replace /\$USER_NAME/g, atom.config.get('epitools.headers.name') or ''
            .replace /\$USER_LOGIN/g, atom.config.get('epitools.headers.login') or ''
            .replace /\$USER_EMAIL/g, atom.config.get('epitools.headers.email') or ''
            .replace /\$DATE/g, @generateDate()

    updateHeader: (editor) ->

    generateHeader: (editor, project='') ->
        scope = editor.getRootScopeDescriptor().scopes[0]
        format = headersFormat.scopes[scope] or headersFormat.scopes.default
        str = format.head + '\n'
        for line in headersFormat.text
            str += format.body + ' ' + line + '\n'
        str += format.tail + '\n'
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
