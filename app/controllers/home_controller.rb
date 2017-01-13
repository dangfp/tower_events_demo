class HomeController < ApplicationController
  def index
    @current_team_id = current_team.id
  end
end
