# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

DEFAULT_PASSWORD = '111111'
CREATED_AT      = DateTime.current - 1.day

def main
  puts 'Seeding data...'

  seed_users_data
  seed_teams_data
  seed_projects_data
  seed_todos_data
  seed_actions_data
  seed_accesses_data

  puts 'Seed data done.'
end

def seed_users_data
  users = [
    { name: 'ava',     email: 'ava@test.com' },
    { name: 'rainbow', email: 'rainbow@test.com' }
  ]

  puts 'Createing users...'
  users.each do |user|
    User.find_or_initialize_by(email: user[:email]).tap do |u|
      u.name                  = user[:name]
      u.password              = DEFAULT_PASSWORD
      u.password_confirmation = DEFAULT_PASSWORD
      u.save!
    end
  end
  puts 'Create users done.'
end

def seed_teams_data
  puts 'Creating teams...'
  Team.find_or_create_by!(title: 'team_1', creator_id: User.first.id)
  puts 'Cread teams done.'
end

def seed_projects_data
  team_id = Team.first.id
  user_id = User.first.id
  projects = [
    { name: 'project_1', creator_id: user_id, project_type: 1 },
    { name: 'project_2', creator_id: user_id, project_type: 0 }
  ]
  puts 'Creating projectings...'
  projects.each do |project|
    Project.find_or_initialize_by(creator_id: user_id, team_id: team_id, name: project[:name]).tap do |p|
      p.project_type = project[:project_type]
      p.save!
    end
  end
  puts 'Creating projectings done.'
end

def seed_todos_data
  first_user       = User.first
  last_user        = User.last
  first_project_id = Project.first.id
  last_project_id  = Project.last.id

  puts 'Creating todos...'
  10.times do |n|
    Todo.find_or_initialize_by(name: "todo_#{n+1}").tap do |todo|
      if n <= 3
        if n.even?
          todo.priority = '!!!'
          todo.tag      = 'API'
        end
        todo.project_id   = last_project_id
        todo.creator_id   = last_user.id
      else
        todo.project_id   = first_project_id
        todo.creator_id   = first_user.id
      end
      todo.save!
    end
  end
  puts 'Creating todos done.'
end

def seed_actions_data
  first_user = User.first
  last_user  = User.last
  first_todo = Todo.first
  last_todo  = Todo.last
  project    = Project.last

  puts 'Creating actions...'
  # 修改任务状态
  first_todo.do_start!   if first_todo.may_do_start?
  first_todo.do_pause!   if first_todo.may_do_pause?
  last_todo.do_complete! if last_todo.may_do_complete?
  last_todo.do_reopen!   if last_todo.may_do_reopen?
  # 为任务分配责任人与完成时间
  last_todo.update_attributes(assignee_id: last_user.id, assignee_name: last_user.name)
  last_todo.update_attributes(assignee_id: first_user.id, assignee_name: first_user.name)
  first_todo.update_attribute(:due, (DateTime.current + 2.days))
  first_todo.update_attribute(:due, (DateTime.current + 3.days))

  # 项目归档
  project.do_archive! if project.may_do_archive?
  # 项目重新激活
  project.do_activate! if project.may_do_activate?

  puts 'Creating actions done.'
end

def seed_accesses_data
  first_user_id             = User.first.id
  last_user_id              = User.last.id
  first_project_resource_id = Project.first.resource.id
  last_project_resource_id  = Project.last.resource.id
  team_resource_id          = Team.first.resource.id
  [team_resource_id, first_project_resource_id, last_project_resource_id].each do |v|
    Access.find_or_create_by(user_id: first_user_id, resource_id: v)
  end
  [team_resource_id, first_project_resource_id].each do |v|
    Access.find_or_create_by(user_id: last_user_id, resource_id: v)
  end
end

# 调用主执行方法
main
