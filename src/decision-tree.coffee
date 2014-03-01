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
    # Don't render until it's in a tree and knows its key.

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

  reset: (value) ->
    @el.reset()
    # Display values passed in.

class DecisionTree
  @tasks = {}

  @registerTask = (taskClass) ->
    @tasks[taskClass::type] = taskClass

  tasks: null

  backLabel: 'Back'

  TASK: 'decision-tree:task'
  CHANGE: 'decision-tree:change'
  CONFIRM: 'decision-tree:confirm'
  COMPLETE: 'decision-tree:complete'
  RESET: 'decision-tree:reset'

  currentTask: null
  taskChain: null
  valueChain: null

  constructor: (options = {}) ->
    @taskChain = []
    @valueChain = []

    @[key] = value for key, value of options
    @tasks ?= {}

    @createRoot()
    @createBackButton()
    @addTasks()

  createRoot: ->
    @el = document.createElement 'div'
    @el.className = 'decision-tree'
    @el.addEventListener 'change', this, false
    @el.addEventListener 'submit', this, false

  createBackButton: ->
    @backButton = document.createElement 'button'
    @backButton.type = 'button'
    @backButton.name = 'decision-tree-go-back'
    @backButton.textContent = @backLabel
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
    handler = switch e.target
      when @backButton
        switch e.type
          when 'click' then @goBack
      else
        switch e.type
          when 'change' then @handleChange
          when 'submit' then @handleSubmit

    handler?.call this, e

  handleChange: (e) ->
    @valueChain[@valueChain.length - 1] = @currentTask.getValue()

    @_dispatchEvent @CHANGE,
      key: @currentTask.key
      value: @valueChain[@valueChain.length - 1]

  handleSubmit: (e) ->
    @valueChain[@valueChain.length - 1] = @currentTask.getValue()

    @_dispatchEvent @CONFIRM,
      key: @currentTask.key
      value: @valueChain[@valueChain.length - 1]

    @loadTask @currentTask.getNext()

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

      @_dispatchEvent @CHANGE
      @_dispatchEvent @TASK, @currentTask

    else
      @_dispatchEvent @COMPLETE,
        value: @getValues()

  goBack: ->
    unless @taskChain.length is 1
      @taskChain.pop()
      @valueChain.pop()
      @loadTask @taskChain.pop(), @valueChain.pop()

  getValues: ->
    for key, i in @taskChain
      result = {}
      result[key] = @valueChain[i] ? null
      result

  reset: ->
    for taskKey, task of @tasks
      task.reset()

    @taskChain.splice 0
    @valueChain.splice 0

    @_dispatchEvent @RESET

  _dispatchEvent: (eventName, detail) ->
    console?.log this, eventName, detail if +location.port > 1023
    e = document.createEvent 'CustomEvent'
    e.initCustomEvent eventName, true, true, detail
    @el.dispatchEvent e

DecisionTree.Task = Task
window.DecisionTree = DecisionTree
module?.exports = DecisionTree
