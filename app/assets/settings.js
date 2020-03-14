$(function(){
  updateTextAreaLengthCounter.call($("#automated_reply")[0]);
  $("#automated_reply").bind("input propertychange", updateTextAreaLengthCounter);
});
