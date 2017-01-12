module Eventable
  extend ActiveSupport::Concern

  included do
    OBJS_OF_SREATE_EVENT_ON_DESTROY = %w(Project).freeze

    # TODO: 应动态获取，暂时硬编码
    RequestStore.store[:current_team] ||= Team.last
    RequestStore.store[:current_user] ||= User.last
    after_create :event_on_create
    after_update :event_on_update, if: :need_create_event_on_update?
    after_destroy :event_on_destroy, if: Proc.new { |obj| OBJS_OF_SREATE_EVENT_ON_DESTROY.include?(obj.class.name) }

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

    def get_indirect_data(on)
      type = self.class.name
      indirect_data = case type
                      when 'Team'
                        get_indirect_data_of_team(on, type)
                      when 'Project'
                        get_indirect_data_of_project(on, type)
                      end
    end

    def get_indirect_data_of_team(on, type)
      {
        ancestor: { id: id, type: type, name: title },
        trackable_name: title,
        action: "#{type.downcase}_#{on}"
      }
    end

    def get_indirect_data_of_project(on, type)
      {
        ancestor: { id: id, type: type, name: name },
        trackable_name: name,
        action: get_action_of_project(on)
      }
    end

    def get_action_of_project(on)
      if on == 'update' && status_changed?
        "project_#{status}"
      else
        "project_#{on}"
      end
    end

    def need_create_event_on_update?
      type = self.class.name
      case type
      when 'Team'
        false
      when 'Project'
        status_changed?
      end
    end

    def create_event(indirect_data)
      type = self.class.name
      attrs = {
        team_id: type == 'Team' ? id : RequestStore.store[:current_team].id,
        resource_id: resource.id,
        actor_id: RequestStore.store[:current_user].id,
        actor_name: RequestStore.store[:current_user].name,
        actor_avatar: RequestStore.store[:current_user].avatar || 'defalult_avatar.jpg',
        trackable_id: id,
        trackable_type: type,
        trackable_name: indirect_data[:trackable_name],
        ancestor_id: indirect_data[:ancestor][:id],
        ancestor_type: indirect_data[:ancestor][:type],
        ancestor_name: indirect_data[:ancestor][:name],
        action: indirect_data[:action]
      }
      Event.create!(attrs)
    end
  end
end
