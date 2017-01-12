module Eventable
  extend ActiveSupport::Concern

  included do
    # TODO: 应动态获取，暂时硬编码
    RequestStore.store[:current_team] ||= Team.last
    RequestStore.store[:current_user] ||= User.last
    after_create :event_on_create
    after_update :event_on_update, if: Proc.new { need_create_event_on_update? }
    after_destroy :event_on_destroy, if: Proc.new { need_create_event_on_destroy? }

    private

    def event_on_create
      indirect_data = get_indirect_data('create')
      create_event(indirect_data)
    end

    def event_on_update
      indirect_data = get_indirect_data('update')
      create_event(indirect_data)
    end

    def event_on_destroy
      indirect_data = get_indirect_data('destroy')
      create_event(indirect_data)
    end

    def get_indirect_data(on)
      type = self.class.name
      indirect_data = case type
                      when 'Team'
                        get_indirect_data_of_team(on, type)
                      end
    end

    def get_indirect_data_of_team(on, type)
      {
        ancestor: { id: id, type: type, name: title },
        trackable_name: title,
        action: "#{type.downcase}_#{on}"
      }
    end

    def need_create_event_on_update?
      false
    end

    def need_create_event_on_destroy?
      false
    end

    def create_event(indirect_data)
      attrs = {
        team_id: RequestStore.store[:current_team].id,
        resource_id: resource.id,
        actor_id: RequestStore.store[:current_user].id,
        actor_name: RequestStore.store[:current_user].name,
        actor_avatar: RequestStore.store[:current_user].avatar || 'defalult_avatar.jpg',
        trackable_id: id,
        trackable_type: self.class.name,
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
