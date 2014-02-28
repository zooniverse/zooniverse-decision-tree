{Task} = window.DecisionTree ? require './decision-tree'

class ButtonTask extends Task
  type: 'button'

  chosenButton: null

  choiceTemplate: (choice, i) -> "
    <button type='submit' name='#{@key}' value='#{choice.value}' data-choice-index='#{i}'>#{choice.label}</button>
  "

  renderTemplate: ->
    super
    @el.querySelector('.decision-tree-confirmation').style.display = 'none'

  enter: ->
    super
    @el.addEventListener 'click', this, false

  exit: ->
    super
    @el.removeEventListener 'click', this, false

  handleEvent: (e) ->
    if e.type is 'click'
      @handleClick e
    else
      super

  handleClick: (e) ->
    @chosenButton = e.target

  getValue: ->
    choiceIndex = @chosenButton.getAttribute 'data-choice-index'
    choice = @choices[choiceIndex]
    choice.value

window.DecisionTree.ButtonTask = ButtonTask
window.DecisionTree.registerTask ButtonTask
module?.exports = ButtonTask
