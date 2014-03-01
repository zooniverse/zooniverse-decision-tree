{Task} = window.DecisionTree ? require './decision-tree'

class RadioTask extends Task
  type: 'radio'

  choiceTemplate: (choice, i) -> "
    <label>
      <input type='radio' name='#{@key}' value='#{choice.value}' data-choice-index='#{i}'' /> #{choice.label}
    </label>
  "

  getChoice: ->
    checkedInput = @el.querySelector ':checked'
    choiceIndex = checkedInput?.getAttribute 'data-choice-index'
    @choices[choiceIndex]

  getValue: ->
    @getChoice()?.value

  getNext: ->
    choice = @getChoice()
    next = if choice? and 'next' of choice then choice.next else super
    next

  reset: (value) ->
    super
    if value?
      choiceIndex = i for choice, i in @choices when choice.value is value
      @el.querySelector("[data-choice-index='#{choiceIndex}']").checked = true

window.DecisionTree.RadioTask = RadioTask
window.DecisionTree.registerTask RadioTask
module?.exports = RadioTask
