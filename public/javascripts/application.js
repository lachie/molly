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
  
  $('.run', runner).click(function() {
    var text = $('.reason textarea').val(),
      url = runner.data('taskurl'),
      task = url.split('/',4)[3]
    
    if(text.blank()) {
      humanMsg.displayMsg("you need to supply a reason for why you're running this task")
    } else {
      runner.hide()
      humanMsg.displayMsg("running "+task)
      
      $.getJSON(url,function(data) {
        var url = '/'+data['name']+'/log/'+data['last_run_key']
        
        var li = running[data['last_run_key']] = $('<li>').prependTo('.logs')
                                                          .html('right now &mdash; ')
                                                          .addClass('running')
        $('<a>')
          .attr('href',url)
          .text(data['last_run_task'])
          .appendTo(li)
      })
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