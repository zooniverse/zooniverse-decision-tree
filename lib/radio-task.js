// Generated by CoffeeScript 1.7.1
(function() {
  var RadioTask, Task, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Task = ((_ref = window.DecisionTree) != null ? _ref : require('./decision-tree')).Task;

  RadioTask = (function(_super) {
    __extends(RadioTask, _super);

    function RadioTask() {
      return RadioTask.__super__.constructor.apply(this, arguments);
    }

    RadioTask.prototype.type = 'radio';

    RadioTask.prototype.choiceTemplate = function(choice, i) {
      return "<label> <input type='radio' name='" + this.key + "' value='" + choice.value + "' data-choice-index='" + i + "'' /> " + choice.label + " </label>";
    };

    RadioTask.prototype.getChoice = function() {
      var checkedInput, choiceIndex;
      checkedInput = this.el.querySelector(':checked');
      choiceIndex = checkedInput != null ? checkedInput.getAttribute('data-choice-index') : void 0;
      return this.choices[choiceIndex];
    };

    RadioTask.prototype.getValue = function() {
      var _ref1;
      return (_ref1 = this.getChoice()) != null ? _ref1.value : void 0;
    };

    RadioTask.prototype.getNext = function() {
      var choice, next;
      choice = this.getChoice();
      next = (choice != null) && 'next' in choice ? choice.next : RadioTask.__super__.getNext.apply(this, arguments);
      return next;
    };

    return RadioTask;

  })(Task);

  window.DecisionTree.RadioTask = RadioTask;

  window.DecisionTree.registerTask(RadioTask);

  if (typeof module !== "undefined" && module !== null) {
    module.exports = RadioTask;
  }

}).call(this);