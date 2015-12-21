{CompositeDisposable, TextEditor} = require 'atom'
path = require 'path'
headersFormat = require './headers-format.json'

module.exports =
class EpitoolsHeaders
    activate: (state) ->
        console.log headersFormat
        @subscriptions = new CompositeDisposable
        # Register command
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-top': => @insertHeaderTop()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-cursor': => @insertHeaderCursor()

    deactivate: ->
        @subscriptions.dispose()

    refresh: (editor, activate) ->

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

    replaceInfo: (header, editor) ->
        filePath = editor.getBuffer().getPath()
        header.replace /\$FILE_NAME/g, path.basename filePath
            .replace /\$PATH/g, path.dirname filePath
            .replace /\$PROJECT/g, 'project'
            .replace /\$USER_NAME/g, process.env.USER_NICKNAME or ''
            .replace /\$USER_LOGIN/g, process.env.USER or ''
            .replace /\$USER_EMAIL/g, ''
            .replace /\$DATE/g, @generateDate()

    updateHeader: (editor) ->

    generateHeader: (editor) ->
        # generate header
        project = '' # TODO : guess project name
        scope = editor.getRootScopeDescriptor().scopes[0]
        format = headersFormat.scopes[scope] or headersFormat.scopes.default
        str = format.head + '\n'
        for line in headersFormat.text
            str += format.body + ' ' + line + '\n'
        str += format.tail + '\n'
        @replaceInfo str, editor

    insertHeader: (editor, pos) ->
        header = @generateHeader editor
        console.log header

    insertHeaderTop: ->
        editor = atom.workspace.getActivePaneItem()
        return null if editor not instanceof TextEditor
        @insertHeader atom.workspace.getActivePaneItem(), [0, 0]

    insertHeaderCursor: ->
        editor = atom.workspace.getActivePaneItem()
        return null if editor not instanceof TextEditor
        posTab = editor.getCursorBufferPositions()
        for point in posTab
            @insertHeader editor, point
