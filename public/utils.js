var COST_PER_TEXT = 0.0075;
var MAX_SMS_LENGTH = 160;

function updateTextAreaLengthCounter() {
  var lengthCounterSpan = $("#" + this.id + "_length");

  var charsRemaining = MAX_SMS_LENGTH - this.value.length;

  var html;

  if (charsRemaining  < 0) {
    html = "<strong>(" + charsRemaining + ")</strong>";
  }
  else {
    html = "(" + charsRemaining + ")";
  }

  lengthCounterSpan.html(html);
}
