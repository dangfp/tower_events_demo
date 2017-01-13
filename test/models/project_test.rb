require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  setup do
    RequestStore.store[:current_user] ||= users(:user_1)
    RequestStore.store[:current_team] ||= teams(:team_1)
    @current_user = RequestStore.store[:current_user]
    @current_team = RequestStore.store[:current_team]
    @project      = projects(:project_1)
  end

  test 'should create an event after create a new project' do
    project  = Project.create(team_id: @current_team.id, name: 'create_project', creator_id: @current_user.id, project_type: 1)
    event    = Event.last
    resource = Resource.last

    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, 'create'
    assert_equal event.trackable_id, project.id
    assert_equal event.trackable_type, project.class.name
    assert_equal event.trackable_name, project.name
    assert_equal event.ancestor_id, project.id
    assert_equal event.ancestor_type, project.class.name
    assert_equal event.ancestor_name, project.name
  end

  test 'should not create an event after change project name' do
    assert_no_difference('Event.count') do
      @project.update(name: 'change name')
    end
  end

  test 'should create an event after archiving' do
    @project.do_archive!
    assert @project.status_archived?

    event = Event.last
    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "status_archived"
    assert_equal event.trackable_id, @project.id
    assert_equal event.trackable_type, @project.class.name
    assert_equal event.trackable_name, @project.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
  end

  test 'should create an event after activating' do
    @project.do_archive!
    @project.do_activate!
    assert @project.status_activated?

    event = Event.last
    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "status_activated"
    assert_equal event.trackable_id, @project.id
    assert_equal event.trackable_type, @project.class.name
    assert_equal event.trackable_name, @project.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
  end

  test 'should create an event after destroy project' do
    assert_difference('Event.count') do
      @project.destroy
    end
  end

  test 'destroy project should soft delete' do
    @project.destroy
    @project.reload
    assert_not_nil @project.deleted_at
  end
end
