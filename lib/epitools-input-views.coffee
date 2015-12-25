{TextEditor, CompositeDisposable} = require 'atom'

module.exports =
class Input extends HTMLElement
    createdCallback: ->
        @disposables = new CompositeDisposable()

        @classList.add('project-manager-dialog', 'overlay', 'from-top')

        @label = document.createElement('label')
        @label.classList.add('project-manager-dialog-label', 'icon')

        @editor = new TextEditor({mini: true})
        @editorElement = atom.views.getView(@editor)

        @errorMessage = document.createElement('div')
        @errorMessage.classList.add('error')

        @appendChild(@label)
        @appendChild(@editorElement)
        @appendChild(@errorMessage)

        @disposables.add(atom.commands.add 'project-manager-dialog',
            'core:confirm': () => @confirm(),
            'core:cancel': () => @cancel()

        @editorElement.addEventListener('blur', () => @cancel())
        @isAttached()

    attachedCallback: ->
        this.editorElement.focus()

    attach: ->
        atom.views.getView(atom.workspace).appendChild this

    detach: ->
        return false if this.parentNode is 'undefined' or this.parentNode is null

        this.disposables.dispose()
        atom.workspace.getActivePane().activate()
        this.parentNode.removeChild this

    setLabel: (text='', iconClass) ->
        this.label.textContent = text
        if iconClass
            this.label.classList.add(iconClass)

    setInput: (input='', select=false) ->
        this.editor.setText input
        if (select) {
            let range = [[0, 0], [0, input.length]]
            this.editor.setSelectedBufferRange range

    showError: (message='') ->
        this.errorMessage.textContent message

    cancel: ->
        this.detach()
