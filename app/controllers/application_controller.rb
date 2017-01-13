class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # TODO: 应动态获取登录用户以及当前项目，为了演示暂时硬编码
  def current_user
    RequestStore.store[:current_user] ||= User.first
  end

  def current_team
    RequestStore.store[:current_team] ||= Team.first
  end
end
