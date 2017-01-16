class EventsController < ApplicationController
  include AssembleEventsForDisplay

  def index
    resource_ids = current_user.resource_ids # 默认为当前用户能看到的所有类别动态，也可以按照项目筛选，具体筛选功能后续实现
    user_id      = nil                       # 筛选某特定用户的动态，具体功能后续实现

    query_term = if user_id
                   Event.where(team_id: params[:team_id], resource_id: resource_ids, actor_id: user_id)
                 else
                   Event.where(team_id: params[:team_id], resource_id: resource_ids)
                 end
    events_arr = query_term.select(:id, :team_id, :created_at, :actor_id, :actor_name, :actor_avatar, :action, :trackable_id, :trackable_type, :trackable_name, :ancestor_id, :ancestor_type, :ancestor_name, :data).order(id: :desc).page(params[:page]).per(50)
    @events = assemble(events_arr)
  end
end
