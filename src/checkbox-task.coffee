DecisionTree = window.DecisionTree ? require './decision-tree'

class CheckboxTask extends DecisionTree.Task
  @type: 'checkbox'

  choiceTemplate: (choice, i) -> "
    <label>
      <input type='checkbox' name='#{@key}' value='#{choice.value}' data-choice-index='#{i}' /> #{choice.label}
    </label>
  "

  getValue: ->
    checkedInputs = @el.querySelectorAll ':checked'
    for input in checkedInputs
      choiceIndex = input.getAttribute 'data-choice-index'
      choice = @choices[choiceIndex]
      choice.value

  reset: (values) ->
    for input in @el.querySelectorAll('input:checked')
      input.checked = false

    if values?
      for value in values
        choiceIndex = i for choice, i in @choices when choice.value is value
        @el.querySelector("[data-choice-index='#{choiceIndex}']").checked = true

DecisionTree.registerTask CheckboxTask

DecisionTree.CheckboxTask = CheckboxTask
module?.exports = CheckboxTask
