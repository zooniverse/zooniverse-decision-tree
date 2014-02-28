DecisionTree = window.DecisionTree;
RadioTask = DecisionTree.RadioTask;
CheckboxTask = DecisionTree.CheckboxTask;
ButtonTask = DecisionTree.ButtonTask;

window.dt = new DecisionTree({
  tasks: {
    pickOne: new RadioTask({
      question: 'Pick a radio button',
      choices: [{
        value: 'this',
        label: 'This one'
      }, {
        value: 'other',
        label: 'This other one'
      }],
      next: 'pickSome'
    }),

    pickSome: { // NOTE: This is not an instance of Task (yet).
      type: 'checkbox',
      question: 'Check multiple',
      choices: [{
        value: 'x',
        label: 'x'
      }, {
        value: 'y',
        label: 'y'
      }],
      next: 'clickOne'
    },

    clickOne: new ButtonTask({
      question: 'Click one',
      choices: [{
        value: 'a',
        label: 'A'
      }, {
        value: 'b',
        label: 'B'
      }]
    })
  }
});

document.body.appendChild(window.dt.el);

setTimeout(function() {
  var data = {};
  var output = document.getElementById('output');

  function update(e) {
    data[e.detail.key] = e.detail.value;
    output.value = JSON.stringify(data, null, 4);
  }

  addEventListener(dt.CHANGE, update, false);
  addEventListener(dt.CONFIRM, update, false);
});