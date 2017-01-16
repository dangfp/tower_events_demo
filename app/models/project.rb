class Project < ApplicationRecord
  include AASM
  include Resourceable
  include Eventable

  acts_as_paranoid

  # project_type_normal: 标准, project_type_kanban: 看板
  enum project_type: { type_normal: 0, project_type_kanban: 1 }

  has_one :resource, as: :resourceable

  # 项目状态机
  aasm column: :status, no_direct_assignment: true do
    state :status_fresh, initial: true # 新建
    state :status_archived             # 归档
    state :status_activated            # 激活

    # 归档
    event :do_archive do
      transitions from: [:status_fresh, :status_activated], to: :status_archived
    end

    # 归档后重新激活
    event :do_activate do
      transitions from: :status_archived, to: :status_activated
    end
  end
end
