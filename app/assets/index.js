// mini jQuery
function $$(q) {
  var els = document.querySelectorAll(q);
  return (els.length === 1) ? els[0] : els;
};

// AJAX POST
$$.post = (url, data, onload, onerror) => {
  var xhr = new XMLHttpRequest();
  xhr.open('POST', url);
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  xhr.onload = () => {
    if (this.status >= 200 && this.status < 400) {
      onload(this);
    }
    else {
      onerror(this);
    }
  };
  xhr.send(encodeURI(data));
  return xhr;
};

///Websockets

function setWs(callback) {
  var wsProtocol = window.location.protocol == "https:" ? "wss:" : "ws:";

  window.ws = new WebSocket(wsProtocol + "//" + window.location.host + "/ws");
  retryIfClosed(callback);

  window.ws.onopen = function() {
    console.log("websocket opened");
  };
  
  window.ws.onclose = function() {
    console.log("websocket closed!");
    retryIfClosed(callback);
  };
  
  window.ws.onmessage = function(msg) {
    if (msg.data === "__ping__") {
      window.ws.send("__pong__");
    }
    else {
      callback(msg.data);
    }
  };
}

function retryIfClosed(callback) {
  if (!window.ws || window.ws.readyState == 3) {
    setTimeout(function() { setWs(callback) }, 2000);
  }
}

////////////////
// Logs
////////////////

// Unhide the logs part of the page
var logsWrapper = $$('#logs-wrapper');
console.log(logsWrapper);
if (logsWrapper) { // are we on a page with logs?
  logsWrapper.hidden = false
  logsWrapper.setAttribute('aria-live', 'polite'); // screen reader 

  // Append text each time we get data from the websocket
  setWs((message) => {
    var logs = $("#logs");
    logs.append(message);
    logs.scrollTop(logs.prop("scrollHeight"));
  }); 
}

////////////////
// Form counters
////////////////

function getMessage() {
  return $$("#message").value.trim();
}

function getNumberOfAddresses() {
  var potNums = $$("#numbers").value;
  var matches = (potNums.match(/^.*?\S/gm) || []);
  return matches.length;
}

function dollarFormat(amount) {
  return amount.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
}

var COST_PER_TEXT = 0.0075;
var GSM7_REGEX = new RegExp("^[A-Za-z0-9 \\r\\n@£$¥èéùìòÇØøÅå\u0394_\u03A6\u0393\u039B\u03A9\u03A0\u03A8\u03A3\u0398\u039EÆæßÉ!\"#$%&'()*+,\\-./:;&lt;=&gt;?¡ÄÖÑÜ§¿äöñüà]*$");

function padToHundredsPlace(integer) {
  return integer.toString().padStart(3, 0);
}

function updateNumCounters() {
  var message = getMessage();
  var addresses = getNumberOfAddresses();

  // https://www.twilio.com/docs/glossary/what-is-ucs-2-character-encoding
  var isGsm7 = GSM7_REGEX.test(message);
  var encoding = isGsm7 ? 'GSM-7' : 'UCS-2';
  var charsPerSegment = isGsm7 ? 153 : 67;

  var numSegments = Math.ceil(message.length / charsPerSegment);
  var cost = COST_PER_TEXT * addresses * numSegments;

  $("#cost-output").html(dollarFormat(cost));
  $("#numbers-output").html(padToHundredsPlace(addresses));
  $("#message-output").html(
    padToHundredsPlace(message.length) + "/" + padToHundredsPlace(charsPerSegment) + " chars; " +
    encoding + "; " + numSegments + " segments"
  );
}

updateNumCounters();

$("#numbers").bind("input propertychange", updateNumCounters);
$("#message").bind("input propertychange", updateNumCounters);

////////////////
// Form validation and XHR
////////////////

function validateForm() {
  if (getNumberOfAddresses() === 0) {
    alert("Numbers list cannot be empty.");
    return false;
  }

  var messageIsEmpty = $("#message")[0].value.trim().length === 0;
  if (messageIsEmpty) {
    alert("Message cannot be empty.");
    return false;
  }

  return true;
}

function getUserConfirmation() {
  return confirm("Really send texts to " + getNumberOfAddresses() + " potential numbers?");
}

function sendFormXHR(event) {
  // Don't reload the page
  event.preventDefault();

  if (validateForm() && getUserConfirmation()) {
    var form = $("#masstext");
    var data = form.serialize();

    // Use XHR to submit the data
    $.post("/", data, function() {
      console.log("Request sent");
    }).fail(function() {
      logToUser("Request failed to send\n");
    });
  }
}

$("#send_button").on("click", sendFormXHR);