{Task} = window.DecisionTree ? require './decision-tree'

class ButtonTask extends Task
  type: 'button'

  chosenButton: null

  choiceTemplate: (choice, i) -> "
    <button type='button' name='#{@key}' value='#{choice.value}' data-choice-index='#{i}'>#{choice.label}</button>
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

  reset: (value) ->
    if value?
      choiceIndex = i for choice, i in @choices when choice.value is value
      @el.querySelector("[data-choice-index='#{choiceIndex}']")?.focus()

  handleEvent: (e) ->
    super
    if e.type is 'click' and e.target.name is @key
      @chosenButton = e.target
      @confirm()

  getValue: ->
    choiceIndex = @chosenButton?.getAttribute 'data-choice-index'
    choice = @choices[choiceIndex]
    choice?.value

  getNext: ->
    choiceIndex = @chosenButton?.getAttribute 'data-choice-index'
    choice = @choices[choiceIndex]
    if 'next' of choice then choice.next else @next

window.DecisionTree.ButtonTask = ButtonTask
window.DecisionTree.registerTask ButtonTask
module?.exports = ButtonTask
