$(function() {
  var COST_PER_TEXT = 0.0075;

  function appendLog(logChunk) {
    var l = $("#logs");

    l.append(logChunk);
    l.scrollTop(l.prop("scrollHeight"));
  }

  window.ws = null;

  function setWs() {
    var wsProtocol = window.location.protocol == "https:" ? "wss:" : "ws:";

    window.ws = new WebSocket(wsProtocol + "//" + window.location.host + "/ws");
    
    window.ws.onopen = function() { console.log("websocket opened"); };
    window.ws.onclose = function() {
      console.log("websocket closed!");
      checkWs();
    };
    window.ws.onmessage = function(msg) {
      if (msg.data !== "") appendLog(msg.data);
    };
  }

  function checkWs(){
    if (!window.ws || window.ws.readyState == 3) setWs();
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

    var confirmMsg = "Really send text(s) to " + potNums + " potential numbers?";

    if (!confirm(confirmMsg)) return false;

    return true;
  }

  $("#send_button").on("click", function(e) {
    e.preventDefault();

    if (validateForm()) {
      var postData = $("#masstext").serialize();

      $.post("/", postData, function() {
        appendLog("Sent text request\n");
      }).fail(function() {
        appendLog("Text request failed\n");
      });
    }
  });

  function numMessageParts() {
    var num = 0;

    if (!textareaIsEmpty("#message0")) num++;
    if (!textareaIsEmpty("#message1")) num++;
    if (!textareaIsEmpty("#message2")) num++;

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
  };

  updateNumCounters();
  $("#numbers").bind("input propertychange", updateNumCounters);
  $("#message0").bind("input propertychange", updateNumCounters);
  $("#message1").bind("input propertychange", updateNumCounters);
  $("#message2").bind("input propertychange", updateNumCounters);
});