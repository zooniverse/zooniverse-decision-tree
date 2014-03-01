class Task
  type: 'base-task'

  key: ''
  question: ''
  choices: null
  next: null

  confirmLabel: 'OK'

  template: -> "
    <div class='decision-tree-question'>#{@question}</div>

    <div class='decision-tree-choices'>
      #{("
        <div class='decision-tree-choice'>#{@choiceTemplate choice, i}</div>
      " for choice, i in @choices).join '\n'}
    </div>

    <div class='decision-tree-confirmation'>
      <button type='submit' name='decision-tree-confirm'>#{@confirmLabel}</button>
    </div>
  "

  choiceTemplate: (choice, i) -> "
    <div>#{i}: #{choice.label} (#{choice.value})</div>
  "

  constructor: (options = {}) ->
    @[key] = value for key, value of options
    @choices ?= []
    @createRoot()
    @hide()

  createRoot: ->
    @el = document.createElement 'form'
    @el.className = 'decision-tree-task'
    @el.setAttribute 'data-task-type', @type

  renderTemplate: ->
    @el.insertAdjacentHTML 'beforeEnd', @template()

  handleEvent: (e) ->
    handler = switch e.type
      when 'submit' then @handleSubmit

    handler?.call this, e

  handleSubmit: (e) ->
    e.preventDefault()

  show: ->
    @el.style.display = ''

  hide: ->
    @el.style.display = 'none'

  enter: ->
    @show()
    @el.addEventListener 'submit', this, false

  exit: ->
    @el.removeEventListener 'submit', this, false
    @hide()

  getValue: ->
    throw new Error "Define Task::getValue for #{@type}"

  getNext: ->
    # The next task might change depending on the current one.
    @next

  reset: ->
    @el.reset()

class DecisionTree
  @tasks = {}

  @registerTask = (taskClass) ->
    @tasks[taskClass::type] = taskClass

  TASK: 'decision-tree:task'
  CHANGE: 'decision-tree:change'
  CONFIRM: 'decision-tree:confirm'
  COMPLETE: 'decision-tree:complete'
  RESET: 'decision-tree:reset'

  tasks: null

  currentTask: null

  constructor: (options = {}) ->
    for key, value of options
      @[key] = value

    @tasks ?= {}

    @createRoot()

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


    @el.addEventListener 'change', this, false
    @el.addEventListener 'submit', this, false

  createRoot: ->
    @el = document.createElement 'div'
    @el.className = 'decision-tree'

  handleEvent: (e) ->
    handler = switch e.type
      when 'change' then @handleChange
      when 'submit' then @handleSubmit
    handler?.call this, e

  handleChange: (e) ->
    @_dispatchEvent @CHANGE,
      key: @currentTask.key
      value: @currentTask.getValue()

  handleSubmit: (e) ->
    @_dispatchEvent @CONFIRM,
      key: @currentTask.key
      value: @currentTask.getValue()

    @loadTask @currentTask.getNext()

  loadTask: (task) ->
    @currentTask?.exit()

    if typeof task is 'function'
      @loadTask task this
    else if typeof task is 'string'
      @loadTask @tasks[task]
    else if task?
      task.enter()
      @currentTask = task
      @_dispatchEvent @TASK, @currentTask
    else
      @_dispatchEvent @COMPLETE,
        value: @getValues()

  getValues: ->
    values = {}
    for taskKey, task of @tasks
      values[task.key] = task.getValue() ? null
    values

  reset: ->
    for taskKey, task of @tasks
      task.reset()

    @_dispatchEvent @RESET

  _dispatchEvent: (eventName, detail) ->
    console?.log this, eventName, detail if +location.port > 1023
    e = document.createEvent 'CustomEvent'
    e.initCustomEvent eventName, true, true, detail
    @el.dispatchEvent e

DecisionTree.Task = Task
window.DecisionTree = DecisionTree
module?.exports = DecisionTree
