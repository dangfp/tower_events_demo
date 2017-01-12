require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  setup do
    RequestStore.store[:current_user] ||= users(:user_1)
    @current_user = RequestStore.store[:current_user]
  end

  test 'should create an event after create a new team' do
    team     = Team.create(title: 'team_1', creator_id: @current_user.id)
    event    = Event.last
    resource = Resource.last

    assert_equal event.team_id, team.id
    assert_equal event.resource_id, resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, 'team_create'
    assert_equal event.trackable_id, team.id
    assert_equal event.trackable_type, team.class.name
    assert_equal event.trackable_name, team.title
    assert_equal event.ancestor_id, team.id
    assert_equal event.ancestor_type, team.class.name
    assert_equal event.ancestor_name, team.title
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
