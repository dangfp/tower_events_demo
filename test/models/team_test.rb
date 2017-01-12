require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  setup do
    RequestStore.store[:current_user] ||= users(:usr)
  end

  test 'should create an event after create a new team' do
    team = Team.create(title: 'team_1', creator_id: RequestStore.store[:current_user].id)
    event = Event.last
    resource = Resource.last
    assert_equal event.resource_id, resource.id
    assert_equal event.trackable_id, team.id
  end

  test 'should not create an event after update team' do
    team = teams(:team_1)
    assert_no_difference('Event.count') do
      team.update(title: 'change title')
    end
  end

  test 'should not create an event after destroy team' do
    team = teams(:team_1)
    assert_no_difference('Event.count') do
      team.destroy
    end
  end
end
