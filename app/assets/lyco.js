/*
lyco.js - part of https://github.com/jackwillis/lyco/
Copyright (C) 2020 Jack Willis

lyco is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
*/

'use strict';

// constants
const COST_PER_TEXT = 0.0075;
const GSM7_REGEX = new RegExp("^[A-Za-z0-9 \r\n@£$¥èéùìòÇØøÅå\u0394_\u03A6\u0393\u039B\u03A9\u03A0\u03A8\u03A3\u0398\u039EÆæßÉ!\"#$%&'()*+,\\-./:;<>?¡ÄÖÑÜ§¿äöñüà]*$");

// mini jQuery
function $(q) {
  const els = document.querySelectorAll(q);
  switch (els.length) {
    case 0: return null;
    case 1: return els[0];
    default: return els;
  }
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
//
// Unhide the logs part of the page
// and display incoming websocket messages
////////////////

var logsWrapper = $('#logs-wrapper');

if (logsWrapper) {
  logsWrapper.hidden = false;
  logsWrapper.setAttribute('aria-live', 'polite'); // screen reader 

  // Append text each time we get data from the websocket
  setWs((message) => {
    var date = new Date();
    var dateString = date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds() + '.' + date.getMilliseconds();
    var node = document.createTextNode('[' + dateString + '] ' + message);
    $('#logs').prepend(node);
  });
}

////////////////
// Compose form
////////////////

var masstext = $('#masstext');

if (masstext) {
  var numbers = $('#numbers');
  var message = $('#message');

  var getMessageText = () => message.value.trim();
  var getNumAddresses = () => (numbers.value.match(/^.*\S/gm) || []).length;

  // Address count, message length, and cost counters

  function dollarFormat(amount) {
    return amount.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
  }

  function padToHundredsPlace(integer) {
    return integer.toString().padStart(3, 0);
  }

  function updateNumCounters() {
    var messageText = getMessageText();
    var numAddresses = getNumAddresses();

    // https://www.twilio.com/docs/glossary/what-is-ucs-2-character-encoding
    var isGsm7 = GSM7_REGEX.test(messageText);
    var encoding = isGsm7 ? 'GSM-7' : 'UCS-2';
    var charsPerSegment = isGsm7 ? 153 : 67;

    var numSegments = Math.ceil(getMessageText().length / charsPerSegment);
    $('#numbers-output').innerText = padToHundredsPlace(numAddresses);

    var cost = COST_PER_TEXT * numAddresses * numSegments;
    $('#cost-output') .innerText = dollarFormat(cost);
    
    var lengthMessage = padToHundredsPlace(messageText.length) + '/'
    + padToHundredsPlace(charsPerSegment) + ' chars; '
    + encoding + '; ' + numSegments + ' segments';
    $('#message-output').innerText = lengthMessage;
  }

  updateNumCounters();

  [numbers, message].forEach((el) => {
    el.addEventListener('input', updateNumCounters);
    el.addEventListener('propertychange', updateNumCounters);
  });

  // Form validation and XHR

  function validateForm() {
    if (getNumAddresses() === 0) {
      alert("Numbers list cannot be empty.");
      return false;
    }

    if (getMessageText() === 0) {
      alert("Message cannot be empty.");
      return false;
    }

    return true;
  }

  function getUserConfirmation() {
    return confirm("Really send texts to " + getNumAddresses() + " potential numbers?");
  }

  // Validate the form, then use XHR to submit it, to avoid reloading the page
  function sendFormXHR(event) {
    event.preventDefault();

    if (validateForm() && getUserConfirmation()) {
      var data = 'numbers=' + encodeURIComponent($('#numbers').value)
               + '&message=' + encodeURIComponent($('#message').value);

      fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: data
      }).then(() => {
        console.log("Request sent");
      }, () => {
        logToUser("Request failed to send\n");
      });
    }
  }

  $('#send_button').addEventListener("click", sendFormXHR);
}