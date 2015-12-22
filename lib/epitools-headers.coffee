{CompositeDisposable, TextEditor} = require 'atom'
path = require 'path'
headersFormat = require './headers-format.json'

module.exports =
class EpitoolsHeaders
    core: null

    activate: (state, @core) ->
        # core.config.headers = @config
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
            .replace /\$USER_NAME/g, atom.config.get('epitools.headers.name') or ''
            .replace /\$USER_LOGIN/g, atom.config.get('epitools.headers.login') or ''
            .replace /\$USER_EMAIL/g, atom.config.get('epitools.headers.email') or ''
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

    insertHeaderTop: ->
        editor = atom.workspace.getActivePaneItem()
        return null if (editor not instanceof TextEditor) or not @core.isActive
        header = @generateHeader editor
        editor.setTextInBufferRange([[0, 0], [0, 0]], header)

    insertHeaderCursor: ->
        editor = atom.workspace.getActivePaneItem()
        return null if (editor not instanceof TextEditor) or not @core.isActive
