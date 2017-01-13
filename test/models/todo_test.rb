require 'test_helper'

class TodoTest < ActiveSupport::TestCase
  setup do
    RequestStore.store[:current_user] ||= users(:user_1)
    RequestStore.store[:current_team] ||= teams(:team_1)
    @current_user = RequestStore.store[:current_user]
    @current_team = RequestStore.store[:current_team]
    @project      = projects(:project_1)
    @todo         = todos(:todo_1)
  end

  test 'should create an event after create a new todo' do
    assert_difference('Event.count') do
      Todo.create(project_id: @project.id, name: 'create_todo', creator_id: @current_user.id)
    end
  end

  test 'the ancestor and resource of todo event both should be the project' do
    todo  = Todo.create(project_id: @project.id, name: 'new_todo', creator_id: @current_user.id)
    event = Event.last

    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, 'create'
    assert_equal event.trackable_id, todo.id
    assert_equal event.trackable_type, todo.class.name
    assert_equal event.trackable_name, todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
  end

  test 'the priority and tag of todo event both should be in the data' do
    todo  = Todo.create(project_id: @project.id, name: 'new_todo', creator_id: @current_user.id, priority: '!!!', tag: 'test')
    event = Event.last

    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, 'create'
    assert_equal event.trackable_id, todo.id
    assert_equal event.trackable_type, todo.class.name
    assert_equal event.trackable_name, todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
    assert_equal event.data['priority'], '!!!'
    assert_equal event.data['tag'], 'test'
  end

  test 'should create two events after change the due and assignee of todo at the same time' do
    assert_difference('Event.count', 2) do
      @todo.update(due: Date.current, assignee_id: @current_user.id, assignee_name: @current_user.name)
    end
  end

  test 'should not create an event after change todo name' do
    assert_no_difference('Event.count') do
      @todo.update(name: 'change name')
    end
  end

  test 'should create an event after assignment' do
    @todo.update(assignee_id: 1, assignee_name: 'andy')
    event = Event.last

    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "set_assignee"
    assert_equal event.trackable_id, @todo.id
    assert_equal event.trackable_type, @todo.class.name
    assert_equal event.trackable_name, @todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
    assert_equal event.data["assignee_id"], { "prev" => nil, "after" => 1 }
    assert_equal event.data["assignee_name"], { "prev" => nil, "after" => "andy" }
  end

  test 'should create an event after setting due' do
    due = Date.current
    @todo.update(due: due)
    event = Event.last

    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "set_due"
    assert_equal event.trackable_id, @todo.id
    assert_equal event.trackable_type, @todo.class.name
    assert_equal event.trackable_name, @todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
    assert_equal event.data["due"], { "prev" => nil, "after" => due.to_s }
  end

  test 'should create an event after starting todo' do
    @todo.do_start!
    assert @todo.status_start?

    event = Event.last
    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "status_start"
    assert_equal event.trackable_id, @todo.id
    assert_equal event.trackable_type, @todo.class.name
    assert_equal event.trackable_name, @todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
    assert_equal event.data['status'], { "prev" => 'status_fresh', 'after' => 'status_start' }
  end

  test 'should create an event after pausing todo' do
    todo  = todos(:status_start_todo)
    todo.do_pause!
    assert todo.status_pause?

    event = Event.last
    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "status_pause"
    assert_equal event.trackable_id, todo.id
    assert_equal event.trackable_type, todo.class.name
    assert_equal event.trackable_name, todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
    assert_equal event.data['status'], { "prev" => 'status_start', 'after' => 'status_pause' }
  end

  test 'should create an event after completing todo' do
    todo  = todos(:status_pause_todo)
    todo.do_complete!
    assert todo.status_completed?

    event = Event.last
    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "status_completed"
    assert_equal event.trackable_id, todo.id
    assert_equal event.trackable_type, todo.class.name
    assert_equal event.trackable_name, todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
    assert_equal event.data['status'], { "prev" => 'status_pause', 'after' => 'status_completed' }
  end

  test 'should create an event after reopening todo' do
    todo  = todos(:status_completed_todo)
    todo.do_reopen!
    assert todo.status_reopen?

    event = Event.last
    assert_equal event.team_id, @current_team.id
    assert_equal event.resource_id, @project.resource.id
    assert_equal event.actor_id, @current_user.id
    assert_equal event.action, "status_reopen"
    assert_equal event.trackable_id, todo.id
    assert_equal event.trackable_type, todo.class.name
    assert_equal event.trackable_name, todo.name
    assert_equal event.ancestor_id, @project.id
    assert_equal event.ancestor_type, @project.class.name
    assert_equal event.ancestor_name, @project.name
    assert_equal event.data['status'], { "prev" => 'status_completed', 'after' => 'status_reopen' }
  end

  test 'should create an event after destroy todo' do
    assert_difference('Event.count') do
      @todo.destroy
    end
  end
end
