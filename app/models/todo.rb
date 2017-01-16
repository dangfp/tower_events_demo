class Todo < ApplicationRecord
  include AASM
  include Eventable

  acts_as_paranoid

  belongs_to :project

  # 任务状态机
  aasm column: :status, no_direct_assignment: true do
    state :status_fresh, initial: true # 新建
    state :status_start                # 开始处理
    state :status_pause                # 暂停
    state :status_completed            # 完成
    state :status_reopen               # 重新打开

    # 开始处理
    event :do_start do
      transitions from: [:status_fresh, :status_pause, :status_reopen], to: :status_start
    end

    # 暂停
    event :do_pause do
      transitions from: :status_start, to: :status_pause
    end

    # 完成
    event :do_complete do
      transitions from: [:status_fresh, :status_start, :status_pause, :status_reopen], to: :status_completed
    end

    # 重新打开
    event :do_reopen do
      transitions from: :status_completed, to: :status_reopen
    end
  end
end
