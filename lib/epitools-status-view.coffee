module.exports =
class EpitoolsView
    visible: false
    active: false

    # @content: ->
    #     @div class: 'epitools-status', =>
    #         @img class: 'epitools-logo', src 'epitech.ico'

    constructor: (state, @statusBar) ->
        @element = document.createElement 'img'
        @element.classList.add 'epitools-logo'
        @element.src = __dirname + '/epi64.ico'
        @element.height = 16
        @element.width = 16
        # Create root element

    show: ->
        @visible = true
        @statusBarTile = @statusBar.addRightTile(item: this, priority: 1000)

    hide: ->
        @visible = false
        @statusBarTile.destroy()

    turn_on: ->
        @active = true

    turn_off: ->
        @active = false

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
        @hide()
