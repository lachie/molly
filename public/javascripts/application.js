String.prototype.blank = function() {
  return $.trim(this).length == 0
}

$(function() {
  var running = {}
  
  var runner = $('<tr><td colspan="3"></td></tr>').hide()
  $('.runner').appendTo($('td',runner))
    
  $('.cancel',runner).click(function() {
    runner.removeData("taskurl").hide()
    return false
  })
  
  var gotJSON = function(data) {
    var url = '/'+data['name']+'/log/'+data['last_run_key']
    var tr = running[data['last_run_key']] = $('<tr>').prependTo('.logs')
    
    tr.append("<td><img src='/images/running.png'/></a>")
    var td = $('<td>').appendTo(tr)
    tr.append('<td>right now</td>')
    
    $('<a/>')
      .attr('href',url)
      .text(data['last_run_task'])
      .appendTo(td)
  }
  
  $('.run', runner).click(function() {
    var text = $('.reason textarea').val(),
      url = runner.data('taskurl'),
      task = url.split('/',4)[3]
    
    if(text.blank()) {
      humanMsg.displayMsg("you need to supply a reason for why you're running this task")
    } else {
      runner.hide()
      humanMsg.displayMsg("running "+task)
      
      url += '?reason='+text.replace("\n",'\\n')
      
      $.getJSON(url,gotJSON)
    }
      
    return false
  })
  
  $('.run-task').click(function() {
    var href = $(this).attr('href')
    
    runner.data('taskurl',href)
          .insertAfter($(this).parents('tr'))
          .show()
    
    return false;
  })


})