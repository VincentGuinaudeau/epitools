{CompositeDisposable} = require 'atom'

module.exports =
class EpitoolsIndentation
    subscriptions = null

    activate: (state, @core) ->

    deactivate: ->

    refresh: ->
        if @subscriptions
            @subscriptions.dispose()
            @subscriptions = null
        return if not @core.currentEditor.editor
        console.log 'indentaion', @core.currentEditor.active
        editor = @core.currentEditor.editor
        config = @core.editorMap.get editor
        if @core.currentEditor.active
            console.log 'active'
            # backup config
            config.backupConfig =
                softTab: editor.getSoftTabs()
                tabLength: editor.getTabLength()
            editor.setSoftTabs false
            editor.setTabLength 8

            # hook indentation handling
            @subscriptions = new CompositeDisposable
            # @subscriptions.add editor.onWillInsertText (event) ->
            #     console.log event
            # @subscriptions.add editor.getBuffer().onWillChange (event) ->
            #     console.log event
        else if config.backupConfig
            console.log 'back'
            console.log config.backupConfig
            editor.setSoftTabs config.backupConfig.softTab
            editor.setTabLength config.backupConfig.tabLength
            config.backupConfig = null
