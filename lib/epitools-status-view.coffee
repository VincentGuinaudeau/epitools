module.exports =
class EpitoolsView
    visible: false
    active: true

    constructor: (state, @statusBar) ->
        @visible = state?.visible
        @active = state?.active
        @element = document.createElement 'div' # TODO : marging to don't be to close of the left element
        @element.classList.add 'inline-block'
        @element.classList.add 'epitools-status'
        @element.classList.add if @active then 'epitools-active' else 'epitools-inactive'
        @show() if @visible

    show: ->
        @visible = true
        @statusBarTile = @statusBar.addRightTile(item: this, priority: 1000)

    hide: ->
        @visible = false
        @statusBarTile.destroy() if @statusBarTile

    set_visible: (visible) ->
        if (visible != @visible)
            if visible then @show() else @hide()

    turnOn: ->
        @active = true
        @element.classList.remove 'epitools-inactive'
        @element.classList.add 'epitools-active'

    turnOff: ->
        @active = false
        @element.classList.remove 'epitools-active'
        @element.classList.add 'epitools-inactive'

    set_active: (active) ->
        if (active != @active)
            if active then @turnOn() else @turnOff()

    # Returns an object that can be retrieved when package is activated
    serialize: ->
        visible: @visible
        active: @active

    # Tear down any state and detach
    destroy: ->
        @hide()
