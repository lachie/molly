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

  // custom task lists

  $('.task-list')
    .hide()
    .data('task_list',[])
    .bind('show',function() {
      draw_tasks()
      $(this).show()
    })
  
  $('.add-task-list').click(function() {
    $('.task-list').trigger('show')
    return false;
  })
  
  
  function remove_task() {
    var task = $(this).data('task')
    
    var new_task_list = $.grep($('.task-list').data('task_list'),function(elt,i) {
      return elt != task
    })
    
    $('.task-list').data('task_list',new_task_list)
    draw_tasks()
  }
  
  function draw_tasks() {
    var t = $('.task-list .selected').empty()
    
    $($('.task-list').data('task_list')).each(function(index,task) {
      $('<a>')
        .attr('href','#')
        .text('- '+task)
        .appendTo(t)
        .click(remove_task)
        .data('task',task)
        
      t.append(' ')
    })
  }
  
  $('.task-list .candidate').click(function() {
    $('.task-list')
      .data('task_list')
      .push($(this).attr('name'))
      
    draw_tasks()
    return false
  })
  
  $('.task-list .save').click(function() {
    var tasks = $('.task-list').data('task_list')
    
    if(tasks.length < 2) {
      humanMsg.displayMsg("please add at least two tasks")
      return false
    }
    
    var url = [ '', app, 'add_task', encodeURIComponent(tasks.join(',')) ].join('/')
    
    // $('.task-list')
    //   .data('task_list',[])
    //   .hide()
    
    
    document.location = url
    return false
  })

})