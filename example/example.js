DecisionTree = window.DecisionTree;
RadioTask = DecisionTree.RadioTask;
CheckboxTask = DecisionTree.CheckboxTask;
ButtonTask = DecisionTree.ButtonTask;

var demoContainer = document.getElementById('demo-container');
var output = document.getElementById('output');
var startOverButton = document.querySelector('button[name="start-over"]');

window.dt = new DecisionTree({
  name: 'decisions',
  firstTask: 'pickOne',
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
        value: 'again',
        label: 'Again',
        next: 'pickOne'
      }, {
        value: 'end',
        label: 'End'
      }]
    })
  }
});

demoContainer.appendChild(window.dt.el);

function startOver() {
  window.dt.reset();
}

function updateOutput() {
  output.value = JSON.stringify(window.dt.getValues(), null, 4);
}

addEventListener(window.dt.CHANGE, updateOutput, false);
updateOutput();

startOverButton.addEventListener('click', startOver, false);
