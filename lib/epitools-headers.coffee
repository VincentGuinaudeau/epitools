module.exports =
class EpitoolsHeaders
    activate: (subscriptions) ->
        console.log 'activate'
        # Register command
        subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-top': => @insert_header_top()
        subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-cursor': => @insert_header_cursor()

    refresh: (editor, activate) ->

    has_header: (editor) ->

    generate_header: (editor) ->

    insert_header: (pos) ->

    insert_header_top: ->

    insert_header_cursor: ->
        editor = atom.workspace.getActivePaneItem()
        if ()
        pos = editor.getCursorScreenPosition()
