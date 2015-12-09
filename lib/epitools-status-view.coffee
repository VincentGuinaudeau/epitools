module.exports =
class EpitoolsView
    visible: false
    active: true

    constructor: (state, @statusBar) ->
        @visible = state?.visible
        @active = state?.active
        @element = document.createElement 'div'
        @element.classList.add 'inline-block'
        @element.classList.add 'epitools-status'
        @element.classList.add if @active then 'epitools-active' else 'epitools-inactive'
        @show() if @visible

    show: ->
        @visible = true
        @statusBarTile = @statusBar.addRightTile(item: this, priority: 1000)

    hide: ->
        @visible = false
        @statusBarTile.destroy()

    turn_on: ->
        @active = true
        @element.classList.remove 'epitools-inactive'
        @element.classList.add 'epitools-active'

    turn_off: ->
        @active = false
        @element.classList.remove 'epitools-active'
        @element.classList.add 'epitools-inactive'

    # Returns an object that can be retrieved when package is activated
    serialize: ->
        visible: @visible
        active: @active

    # Tear down any state and detach
    destroy: ->
        @hide()
