{TextEditor, CompositeDisposable} = require 'atom'

module.exports =
class Input extends HTMLElement
    isRemoving: false

    constructor: (placeholder) ->
        @element = document.createElement 'epitools-input'
        @element.classList.add 'epitools-dialog', 'overlay', 'from-top'

        # @label = document.createElement 'label'
        # @label.classList.add 'epitools-dialog-label', 'icon'

        @editor = new TextEditor
            mini: true
        @editor.setPlaceholderText placeholder
        @editorElement = atom.views.getView @editor

        @errorMessage = document.createElement 'div'
        @errorMessage.classList.add 'error'

        # @element.appendChild @label
        @element.appendChild @editorElement
        @element.appendChild @errorMessage

        @editorElement.addEventListener 'blur', @cancel.bind(this)

    getText: ->
        @editor.getText()

    onConfirm: ->
        @confirm @getText()

    setConfirm: (confirm) ->
        @confirm = confirm

    attach: ->
        @disposable = atom.commands.add 'body',
            'core:confirm': => @onConfirm()
            'core:cancel': => @cancel()

        atom.views.getView(atom.workspace).appendChild @element
        @editorElement.focus()

    detach: ->
        return false if (not @element.parentNode?.contains @element) or @isRemoving

        @isRemoving = true
        @disposable.dispose()
        @element.parentNode.removeChild @element
        atom.workspace.getActivePane().activate()
        @isRemoving = false

    # setLabel: (text='', iconClass) ->
    #     @label.textContent = text
    #     if iconClass
    #         @label.classList.add(iconClass)

    setInput: (input='', select=false) ->
        @editor.setText input
        if (select)
            range = [[0, 0], [0, input.length]]
            @editor.setSelectedBufferRange range

    showError: (message='') ->
        @errorMessage.textContent message

    cancel: ->
        @detach()
