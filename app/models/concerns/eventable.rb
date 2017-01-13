module Eventable
  extend ActiveSupport::Concern

  included do
    OBJS_OF_CREATE_EVENT_ON_DESTROY      = %w(Project Todo).freeze
    ATTRS_OF_CREATE_EVENT_ON_UPDATE_TODO = %w(assignee_id due status).freeze

    # TODO: 应动态获取，暂时硬编码
    RequestStore.store[:current_team] ||= Team.first
    RequestStore.store[:current_user] ||= User.first

    after_create :event_on_create
    after_update :event_on_update, if: :need_create_event_on_update?
    after_destroy :event_on_destroy, if: Proc.new { |obj| OBJS_OF_CREATE_EVENT_ON_DESTROY.include?(obj.class.name) }

    private

    def event_on_create
      create_event(get_indirect_data('create'))
    end

    def event_on_update
      create_event(get_indirect_data('update'))
    end

    def event_on_destroy
      create_event(get_indirect_data('destroy'))
    end

    # 按照动态信息的特定要求对不同对象的不同动的相关信息作进行整理，以便后续以统一方式进行存储
    def get_indirect_data(on)
      type = self.class.name
      indirect_data = case type
                      when 'Team'
                        get_indirect_data_of_team(on, type)
                      when 'Project'
                        get_indirect_data_of_project(on, type)
                      when 'Todo'
                        get_indirect_data_of_todo(on, type)
                      end
    end

    def get_indirect_data_of_team(on, type)
      {
        ancestor: { id: id, type: type, name: title },
        trackable_name: title,
        action: "#{on}"
      }
    end

    ## begin project相关处理逻辑
    def get_indirect_data_of_project(on, type)
      {
        ancestor: { id: id, type: type, name: name },
        trackable_name: name,
        action: get_action_of_project(on)
      }
    end

    def get_action_of_project(on)
      if on == 'update'
        "#{status}"
      else
        "#{on}"
      end
    end
    ## end

    ## begin todo相关处理逻辑
    # 任务的祖先应为所属项目
    # 任务在创建时可以同时设置名称、优先级、标签、执行者以及到期时间，但只记录创建动作的动态信息，所以不再另外设置执行者和到期时间两个动作的动态信息
    def get_indirect_data_of_todo(on, type)
      indirect_data = []
      get_action_and_data_of_todo(on).each do |a_d|
        indirect_data << {
                            ancestor: { id: project.id, type: project.class.name, name: project.name },
                            trackable_name: name,
                            action: a_d[:action],
                            data: a_d[:data] ? a_d[:data].merge!("priority": priority, "tag": tag) : { "priority": priority, "tag": tag } # 任务的优先级、标签均作为附加数据
                          }
      end
      indirect_data
    end

    def get_action_and_data_of_todo(on)
      actions_and_data_arr = []
      if on == 'update'
        (ATTRS_OF_CREATE_EVENT_ON_UPDATE_TODO & changes.keys).each do |k|
          actions_and_data_arr << case k
                                  when 'assignee_id'
                                    {
                                      action: 'set_assignee',
                                      data: {
                                        "assignee_id": {
                                          "prev": changes[k].first,
                                          "after": changes[k].last
                                        },
                                        "assignee_name": {
                                          "prev": changes['assignee_name'].first,
                                          "after": changes['assignee_name'].last
                                        }
                                      }
                                    }
                                  when 'due'
                                    {
                                      action: 'set_due',
                                      data: {
                                        "due": {
                                          "prev": changes[k].first.try(:strftime, '%F'),
                                          "after": changes[k].last.try(:strftime, '%F')
                                        }
                                      }
                                    }
                                  when 'status'
                                    {
                                      action: "#{changes[k].last}",
                                      data: {
                                        "status": {
                                          "prev": changes[k].first,
                                          "after": changes[k].last
                                        }
                                      }
                                    }
                                  end
        end
      else
        actions_and_data_arr << { action: "#{on}" }
      end
      actions_and_data_arr
    end
    ## end

    def need_create_event_on_update?
      type = self.class.name
      case type
      when 'Team'
        false
      when 'Project'
        status_changed?
      when 'Todo'
        !(ATTRS_OF_CREATE_EVENT_ON_UPDATE_TODO & changes.keys).empty?
      end
    end

    def create_event(indirect_data)
      type = self.class.name
      i_d_arr = indirect_data.instance_of?(Array) ? indirect_data : [indirect_data]
      i_d_arr.each do |i_d|
        attrs = {
          team_id: type == 'Team' ? id : RequestStore.store[:current_team].id,
          resource_id: type == 'Todo' ? project.resource.id : resource.id,
          actor_id: RequestStore.store[:current_user].id,
          actor_name: RequestStore.store[:current_user].name,
          actor_avatar: RequestStore.store[:current_user].avatar || 'defalult_avatar.jpg',
          trackable: self,
          trackable_name: i_d[:trackable_name],
          ancestor_id: i_d[:ancestor][:id],
          ancestor_type: i_d[:ancestor][:type],
          ancestor_name: i_d[:ancestor][:name],
          action: i_d[:action],
          data: i_d[:data]
        }
        Event.create!(attrs)
      end
    end
  end
end
