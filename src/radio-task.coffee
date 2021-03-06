DecisionTree = window.DecisionTree ? require './decision-tree'

class RadioTask extends DecisionTree.Task
  @type: 'radio'

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
    @el.querySelector('input:checked')?.checked = false

    if value?
      choiceIndex = i for choice, i in @choices when choice.value is value
      @el.querySelector("[data-choice-index='#{choiceIndex}']").checked = true

DecisionTree.registerTask RadioTask

DecisionTree.RadioTask = RadioTask
module?.exports = RadioTask
