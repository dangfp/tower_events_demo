module EventsHelper
  def get_ancestor_show_path(ancestor_id, ancestor_type)
    case ancestor_type
    when 'Team'
      team_path(ancestor_id)
    when 'project'
      project_path(ancestor_id)
    when 'Calendar'
      calendar_path
    when 'Weekly'
      weekly_path
    end
  end
end
