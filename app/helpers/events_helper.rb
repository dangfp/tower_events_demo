module EventsHelper
  def get_ancestor_show_path(ancestor_id, ancestor_type)
    send("#{ancestor_type.downcase}_path", ancestor_id)
  end

  def format_action_for_display(action, trackable_type, data)
    case action
    when 'create', 'destroy'
      I18n.t(action, scope: "activerecord.attributes.event.#{trackable_type.downcase}.action_enum", default: '')
    when 'status_archived', 'status_activated', 'status_start', 'status_pause', 'status_completed', 'status_reopen'
      I18n.t(action, scope: "activerecord.attributes.event.#{trackable_type.downcase}.status_enum", default: '')
    when 'set_assignee'
      format_set_assignee_for_display(data)
    when 'set_due'
      format_set_due_for_display(data)
    end
  end

  def format_set_assignee_for_display(data)
    prev  = data[:assignee_name][:prev]
    after = data[:assignee_name][:after]

    return "给 #{after} 指派了任务" if prev.nil?
    return "取消了 #{prev} 的任务" if after.nil?
    "将 #{prev} 的任务指派给 #{after}"
  end

  def format_set_due_for_display(data)
    prev  = data[:due][:prev]
    after = data[:due][:after]

    return "将任务完成时间从 没有截止日期 修改为 #{after}" if prev.nil?
    return "将任务完成时间从 #{prev} 修改为 没有截止日期" if after.nil?
    "将任务完成时间从 #{prev} 修改为 #{after}"
  end

  def get_tracking_obj_detail_url(trackable_id, trackable_type)
    send("#{trackable_type.downcase}_path", trackable_id)
  end
end
