/*
lyco.js - part of https://github.com/jackwillis/lyco/
Copyright (C) 2020 Jack Willis

lyco is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.
*/

'use strict'

// constants
const COST_PER_TEXT = 0.0075
const GSM7_REGEX = new RegExp("^[A-Za-z0-9 @£$¥èéùìòÇØøÅåΦ_ΦΓΛΩΠΨΣΘΞÆæßÉ!\"#$%&'()*+,\\-./:;<>?¡ÄÖÑÜ§¿äöñüà]*$", 'm')

// mini jQuery
function $ (q) {
  const els = document.querySelectorAll(q)
  switch (els.length) {
    case 0: return null
    case 1: return els[0]
    default: return els
  }
};

/// Websockets

function setWs (callback) {
  var wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'

  window.ws = new WebSocket(wsProtocol + '//' + window.location.host + '/ws')
  retryIfClosed(callback)

  window.ws.onopen = function () {
    console.log('websocket opened')
  }

  window.ws.onclose = function () {
    console.log('websocket closed!')
    retryIfClosed(callback)
  }

  window.ws.onmessage = function (msg) {
    if (msg.data === '__ping__') {
      window.ws.send('__pong__')
    } else {
      callback(msg.data)
    }
  }
}

function retryIfClosed (callback) {
  if (!window.ws || window.ws.readyState === 3) {
    setTimeout(function () { setWs(callback) }, 2000)
  }
}

/// /////////////
// Logs controller
//
// Unhide the logs part of the page
// and display incoming websocket messages
/// /////////////

function log (message) {
  const date = new Date()
  const dateString = date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds() + '.' + date.getMilliseconds()
  const text = '[' + dateString + '] ' + message
  const logs = $('#logs')
  return logs && logs.prepend(document.createTextNode(text))
}

const logsWrapper = $('#logs-wrapper')

if (logsWrapper) {
  logsWrapper.hidden = false
  logsWrapper.setAttribute('aria-live', 'polite') // screen reader

  // Append text each time we get data from the websocket
  setWs(log)
}

/// ///////////////////
// Compose controller
/// ///////////////////

const masstext = $('#masstext')

if (masstext) {
  const numbers = $('#numbers')
  const message = $('#message')

  function getMessageText () {
    return message.value.trim()
  }

  function getNumAddresses () {
    return (numbers.value.match(/^.*\S/gm) || []).length
  }

  function padToHundredsPlace (integer) {
    return integer.toString().padStart(3, 0)
  }

  // Address count, message length, and cost counters

  function updateMassTextCounters () {
    const messageText = getMessageText()
    const numAddresses = getNumAddresses()

    // https://www.twilio.com/docs/glossary/what-is-ucs-2-character-encoding
    const isGsm7 = GSM7_REGEX.test(messageText)
    const encoding = isGsm7 ? 'GSM-7' : 'UCS-2'
    const charsPerSegment = isGsm7 ? 153 : 67
    const messageLength = messageText.length
    const numSegments = Math.ceil(messageLength / charsPerSegment)
    const cost = COST_PER_TEXT * numAddresses * numSegments
    const costFormatted = cost.toLocaleString('en-US', { style: 'currency', currency: 'USD' })

    $('#numbers-output').innerText = padToHundredsPlace(numAddresses)
    $('#cost-output').innerText = costFormatted
    $('#message-output').innerText = padToHundredsPlace(messageLength) + '/' +
    padToHundredsPlace(charsPerSegment) + ' chars; ' +
    encoding + '; ' + numSegments + ' segments'
  }

  updateMassTextCounters()
  masstext.addEventListener('input', updateMassTextCounters)
  masstext.addEventListener('propertychange', updateMassTextCounters)

  // Form validation and XHR

  function validateForm () {
    if (getNumAddresses() === 0) {
      alert('Numbers list cannot be empty.')
      return false
    }

    if (getMessageText() === 0) {
      alert('Message cannot be empty.')
      return false
    }

    return true
  }

  function getUserConfirmation () {
    return confirm('Really send texts to ' + getNumAddresses() + ' potential numbers?')
  }

  // Custom behavior for submitting the form.
  // Validate the form, confirm action with popup, then use AJAX to submit the form.
  // This avoids reloading the page.
  function submitForm (event) {
    event.preventDefault()

    if (validateForm() && getUserConfirmation()) {
      fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'numbers=' + encodeURIComponent(numbers.value) +
        '&message=' + encodeURIComponent(message.value)
      }).then(() => log('Request sent\n'), () => log('Request failed to send\n'))
    }
  }
  masstext.addEventListener('submit', submitForm)
}
