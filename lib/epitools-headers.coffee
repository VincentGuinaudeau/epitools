{CompositeDisposable} = require 'atom'
headers = require './headers-format'

module.exports =
class EpitoolsHeaders
    activate: (state) ->
        @subscriptions = new CompositeDisposable
        # Register command
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-top': => @insertHeaderTop()
        @subscriptions.add atom.commands.add 'atom-workspace', 'epitools:header-cursor': => @insertHeaderCursor()

    refresh: (editor, activate) ->

    hasHeader: (editor) ->

    updateHeader: (editor) ->

    generateHeader: (editor) ->


    insertHeader: (pos) ->

    insertHeaderTop: ->

    insertHeaderCursor: ->
