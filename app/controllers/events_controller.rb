class EventsController < ApplicationController
  def index
    # TODO: 所需环境变量和筛选参数应动态获取，目前为了演示暂时硬编码
    current_team ||= Team.find 1
    current_user ||= User.find 1
    resource_ids = [1, 2]
    user_id     = nil

    query_term = if user_id
                   Event.where(team_id: current_team.id, resource_id: resource_ids, user_id: user_id)
                 else
                   Event.where(team_id: current_team.id, resource_id: resource_ids)
                 end
    # TODO: 应补充分页
    events_arr = query_term.select(:id, :team_id, :created_at, :actor_id, :actor_name, :actor_avatar, :action, :trackable_id, :trackable_type, :trackable_name, :ancestor_id, :ancestor_type, :ancestor_name, :data).order(created_at: :desc).first(50)
    @events = assemble_events(events_arr)
  end

  private

  # 对动态数据进行组装以满足页面展示的要求
  # 结构样例如下:
  # [
  #   {
  #     "date": "2017-01-10",
  #     "items": [
  #       {
  #         "ancestor_id": 1,
  #         "ancestor_type": "project",
  #         "ancestor_name": "first project",
  #         "events": [
  #           {
  #             "action": "aaa",
  #             "actor_id": 1
  #           },
  #           {
  #             "action": "bbb",
  #             "actor_id": 1
  #           }
  #         ]
  #       },
  #       {
  #         "ancestor_name": "calendar",
  #         "events": [
  #           {
  #             "action": "ccc",
  #             "actor_id": 1
  #           }
  #         ]
  #       }
  #     ]
  #   },
  #   {
  #     "date": "2017-01-09",
  #     "items": [
  #       {
  #         "ancestor_id": 1,
  #         "ancestor_type": "Weekly",
  #         "ancestor_name": "weekly",
  #         "events": [
  #           {
  #             "action": "ddd",
  #             "actor_id": 1
  #           }
  #         ]
  #       }
  #     ]
  #   }
  # ]
  def assemble_events(events_arr)
    assembled_result = []

    # 按日期分组
    events_arr.group_by { |data| data[:created_at].to_date }.each do |k, v|
      grouped_by_date        = {}
      grouped_by_date[:date] = k.strftime('%F')
      items                  = []
      # 将连续的动态按照祖先分组
      v.reduce([]) { |accu, obj| consecutive?(accu.flatten.last, obj) ? (accu.last << obj; accu) : accu << [obj] }.each do |e|
        hash                 = {}
        hash[:ancestor_id]   = e.first.ancestor_id
        hash[:ancestor_type] = e.first.ancestor_type
        hash[:ancestor_name] = e.first.ancestor_name
        hash[:events]        = e
        items << hash
      end
      grouped_by_date[:items] = items
      assembled_result << grouped_by_date
    end

    assembled_result
  end

  # 定义连续的判断标准
  def consecutive?(x,y)
    x.try(:ancestor_id) == y.try(:ancestor_id)
  end
end
