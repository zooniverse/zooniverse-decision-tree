class Base
  dispatchEvent: (eventName, detail) ->
    e = document.createEvent 'CustomEvent'
    e.initCustomEvent eventName, true, true, detail
    @el.dispatchEvent e

class Task extends Base
  type: 'base-task'

  key: ''
  question: ''
  choices: null
  next: null

  confirmButtonLabel: 'OK'
  confirmButtonName: 'decision-tree-confirm-task'

  CONFIRM: 'decision-tree:task-confirm'

  template: -> "
    <div class='decision-tree-question'>#{@question}</div>

    <div class='decision-tree-choices'>
      #{("
        <div class='decision-tree-choice'>#{@choiceTemplate choice, i}</div>
      " for choice, i in @choices).join '\n'}
    </div>

    <div class='decision-tree-confirmation'>
      <button type='button' name='#{@confirmButtonName}'>#{@confirmButtonLabel}</button>
    </div>
  "

  choiceTemplate: (choice, i) -> "\
    <div>#{i}: #{choice.label} (#{choice.value})</div>
  "

  constructor: (options = {}) ->
    @[key] = value for key, value of options
    @choices ?= []

    @createRoot()

    @hide()

  createRoot: ->
    @el = document.createElement 'div'
    @el.className = 'decision-tree-task'
    @el.setAttribute 'data-task-type', @type

  renderTemplate: ->
    @el.innerHTML = @template()
    @setUpConfirmButton()

  setUpConfirmButton: ->
    @confirmButton = @el.querySelector "button[name='#{@confirmButtonName}']"
    @confirmButton.addEventListener 'click', this

  handleEvent: (e) ->
    if e.type is 'click' and e.currentTarget is @confirmButton
      @confirm()

  enter: ->
    @show()
    @el.addEventListener 'click', this, false

  exit: ->
    @el.removeEventListener 'click', this, false
    @hide()

  show: ->
    @el.style.display = ''

  hide: ->
    @el.style.display = 'none'

  confirm: ->
    @dispatchEvent @CONFIRM, @getValue()

  getValue: ->
    throw new Error "Define Task::getValue for #{@type}"

  getNext: ->
    # The next task might change depending on the current one.
    @next

  reset: (value) ->
    throw new Error "Define Task::reset for #{@type}"

class DecisionTree extends Base
  @tasks = {}

  @registerTask = (taskClass) ->
    @tasks[taskClass::type] = taskClass

  name: ''
  tasks: null
  firstTask: null

  backLabel: 'Back'

  LOAD_TASK: 'decision-tree:load-task'
  CHANGE: 'decision-tree:change-values'
  COMPLETE: 'decision-tree:complete-tree'
  RESET: 'decision-tree:reset-tree'

  currentTask: null
  taskChain: null
  valueChain: null

  constructor: (options = {}) ->
    @taskChain = []
    @valueChain = []

    @[key] = value for key, value of options
    @tasks ?= {}

    @createRoot()
    @createInput() if @name
    @createBackButton()
    @addTasks()

    @reset()

  createRoot: ->
    @el = document.createElement 'div'
    @el.className = 'decision-tree'
    @el.addEventListener 'change', this, false
    @el.addEventListener Task::CONFIRM, this, false

  createInput: ->
    @input = document.createElement 'input'
    # @input.type = 'hidden'
    @input.name = @name if @name
    @el.appendChild @input

  createBackButton: ->
    @backButton = document.createElement 'button'
    @backButton.type = 'button'
    @backButton.name = 'decision-tree-go-back'
    @backButton.innerHTML = @backLabel
    @backButton.addEventListener 'click', this, false
    @el.appendChild @backButton

  addTasks: ->
    for taskKey, task of @tasks
      unless task instanceof Task
        if @constructor.tasks[task.type]?
          task = new @constructor.tasks[task.type] task
          @tasks[taskKey] = task
        else
          throw new Error "No registered task #{task.type}"

      unless task.key
        task.key = taskKey

      task.renderTemplate()
      @el.appendChild task.el

  handleEvent: (e) ->
    if e.type is 'click' and e.currentTarget is @backButton
      @goBack()
    else
      handler = switch e.type
        when 'change' then @handleChange
        when Task::CONFIRM then @handleTaskConfirm

      handler?.call this, e

  handleChange: (e) ->
    @syncCurrentValue @currentTask.getValue()

  handleTaskConfirm: (e) ->
    @syncCurrentValue e.detail
    @loadTask @currentTask?.getNext()

  loadTask: (task, value) ->
    @currentTask?.exit()
    @currentTask = null

    if typeof task is 'function'
      @loadTask task, value

    else if typeof task is 'string'
      @loadTask @tasks[task], value

    else if task?
      @currentTask = task
      @currentTask.reset value

      @taskChain.push @currentTask.key
      @valueChain.push @currentTask.getValue()

      @currentTask.enter()

      @backButton.disabled = @taskChain.length is 1

      @dispatchEvent @LOAD_TASK,
        task: @currentTask
        index: @taskChain.length - 1

      @syncCurrentValue @valueChain[@valueChain.length - 1]

    else
      @complete()


  goBack: ->
    unless @taskChain.length is 1
      @taskChain.pop()
      @valueChain.pop()
      @loadTask @taskChain.pop(), @valueChain.pop()

  complete: ->
    @dispatchEvent @COMPLETE,
      value: @getValues()

  syncCurrentValue: (value) ->
    @valueChain[@valueChain.length - 1] = value
    @input?.value = JSON.stringify @getValues()

    @dispatchEvent @CHANGE,
      key: @currentTask?.key
      value: @valueChain[@valueChain.length - 1]

  getValues: ->
    for key, i in @taskChain
      result = {}
      result[key] = @valueChain[i] ? null
      result

  reset: (taskToLoad = @firstTask) ->
    for taskKey, task of @tasks
      task.reset()

    @taskChain.splice 0
    @valueChain.splice 0

    @dispatchEvent @RESET

    if taskToLoad?
      @loadTask taskToLoad
    else
      @syncCurrentValue()

DecisionTree.Task = Task
window.DecisionTree = DecisionTree
module?.exports = DecisionTree
