$(function() {
  function appendLog(logChunk) {
    var l = $("#logs");

    l.append(logChunk);
    l.scrollTop(l.prop("scrollHeight"));
  }

  window.ws = null;

  function setWs() {
    var wsProtocol = window.location.protocol == "https:" ? "wss:" : "ws:";

    window.ws = new WebSocket(wsProtocol + "//" + window.location.host + "/ws");

    window.ws.onopen = function() {
      console.log("websocket opened");
    };
    
    window.ws.onclose = function() {
      console.log("websocket closed!");
      checkWs();
    };
    
    window.ws.onmessage = function(msg) {
      if (msg.data === "__ping__") {
        window.ws.send("__pong__");
      }
      else {
        appendLog(msg.data);
      }
    };

    checkWs();
  }

  function checkWs() {
    if (!window.ws || window.ws.readyState == 3) {
      setTimeout(setWs, 2000);
    }
  }

  setWs();

  function getPotentialNumbers() {
    var potNums = $("#numbers")[0].value;
    var matches = (potNums.match(/^.*?\S/gm) || [])
    return matches.length;
  }

  function textareaIsEmpty(querySelector) {
    return $(querySelector)[0].value.trim().length === 0;
  }

  function textareaIsTooLong(querySelector) {
    return $(querySelector)[0].value.length > MAX_SMS_LENGTH;
  }

  function validateForm() {
    var potNums = getPotentialNumbers();

    if (potNums === 0) {
      alert("Numbers list is empty!");
      return false;
    }

    if (textareaIsEmpty("#message0")) {
      alert("Message part 1 is empty!");
      return false;
    }

    for (var i = 0; i < 2; i++) {
      if (textareaIsTooLong("#message" + i)) {
        alert("Message part " + (i+1) + " is too long!");
        return false;
      }
    }

    var confirmMsg = "Really send texts to " + potNums + " potential numbers?";

    if (!confirm(confirmMsg)) return false;

    return true;
  }

  $("#send_button").on("click", function(e) {
    e.preventDefault();

    if (validateForm()) {
      var postData = $("#masstext").serialize();

      $.post("/", postData, function() {
        appendLog("Sent request to server\n");
      }).fail(function() {
        appendLog("Request failed to send\n");
      });
    }
  });

  function numMessageParts() {
    var num = 0;

    for (var i = 0; i < 2; i++) {
      if (!textareaIsEmpty("#message" + i)) num++;
    }

    return num;
  }

  function updateNumCounters() {
    var potNums = getPotentialNumbers();
    var numParts = numMessageParts();

    $("#potnums").html(potNums);
    $("#numparts").html(numParts);

    var baseCost = COST_PER_TEXT * numParts;

    var roundedCost = String((baseCost * potNums).toPrecision(2));
    var costParts = roundedCost.split(".");

    var costHtml = "$";

    costHtml += costParts[0] + ".";

    var centsPart = costParts[1].slice(0, 2);
    if (centsPart.length === 1) centsPart += "0";

    costHtml += centsPart;

    $("#cost").html(costHtml);
  }

  updateNumCounters();

  $("#numbers").bind("input propertychange", updateNumCounters);

  for (var i = 0; i < 2; i++) {
    var messageTextArea = $("#message" + i);
    messageTextArea.bind("input propertychange", updateNumCounters);
    messageTextArea.bind("input propertychange", updateTextAreaLengthCounter);
  }
});
