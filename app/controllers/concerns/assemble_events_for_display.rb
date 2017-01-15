module AssembleEventsForDisplay

  extend ActiveSupport::Concern

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
  #           { # event详情，此处罗列两项作为说明
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
  def assemble(events)
    assembled_result = []

    # 按日期分组
    events.group_by { |data| data[:created_at].to_date }.each do |k, v|
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

  private

  # 定义连续的判断标准
  def consecutive?(x,y)
    x&.ancestor_id == y&.ancestor_id
  end
end
