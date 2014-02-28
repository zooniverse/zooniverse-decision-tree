{Task} = window.DecisionTree ? require './decision-tree'

class CheckboxTask extends Task
  type: 'checkbox'

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

window.DecisionTree.CheckboxTask = CheckboxTask
window.DecisionTree.registerTask CheckboxTask
module?.exports = CheckboxTask
