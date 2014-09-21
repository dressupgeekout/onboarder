class Onboarder
  EMPTY = /\A\s*\z/

  get("/") do
    erb(:index)
  end

  post("/roles") do
    if params["role-name"] =~ EMPTY
      session[:flash] = [false, "Sorry, please enter a nonblank name."]
      return redirect to("/")
    end

    @@db.transaction do
      @@db[:roles].push(Role.new({
        :name => params["role-name"],
        :user => params["user"],
      }))
    end

    session[:flash] = [true, sprintf("Successfully assigned %s as the %s.",
      user_login_to_pretty(params["user"]), params["role-name"])]
    redirect to("/")
  end

  delete("/roles") do
    if task_map.any? { |t| t.role == params["role-name"] }
      status(403)
      session[:flash] = [
        false,
        "Please remove all of the tasks assigned to the " +
        "#{params["role-name"].inspect} role, first."
      ]
      redirect to("/")
    end

    @@db.transaction do
      @@db[:roles].delete_if { |r| r.name == params["role-name"] }
    end

    session[:flash] = [true,
      "Successfully removed the #{params["role-name"].inspect} role."]
    redirect to("/")
  end

  post("/newhire") do
    name_fields = [params["newhire-name-first"], params["newhire-name-last"]]

    if name_fields.any? { |n| n =~ EMPTY }
      session[:flash] = [false, "Sorry, please enter a nonblank name."]
      status(403)
      return erb(:index)
    end

    if !config(:default_redmine_proj) or config(:default_redmine_proj).empty?
      session[:flash] = [false, "Sorry, please define the Redmine project."]
      status(403)
      return erb(:index)
    end

    if !config(:hiring_manager) or config(:hiring_manager).empty?
      session[:flash] = [false, "Sorry, please establish the hiring manager."]
      status(403)
      return erb(:index)
    end

    if !task_map or task_map.empty?
      session[:flash] = [false, "Sorry, please define at least one task."]
      status(403)
      return erb(:index)
    end

    if !all_roles or all_roles.empty?
      session[:flash] = [false, "Sorry, please define at least one role."]
      status(403)
      return erb(:index)
    end

    newhire_fullname = sprintf("%s %s", params["newhire-name-first"],
      params["newhire-name-last"])

    parent_issue_subject = sprintf("Onboarding %s", newhire_fullname)

    # Post the parent issue
    parent_issue_id = @@redmine_cxn.post_issue({
      "project_id" => default_project_id,
      "subject" => parent_issue_subject,
      "description" => "Parent ticket for onboarding #{newhire_fullname}",
      "assigned_to_id" => user_login_to_id(config(:hiring_manager)),
    })

    all_issue_ids = []
    all_issue_ids << parent_issue_id

    # Now post all of the "real" issues
    task_map.each do |task|
      issue_id = @@redmine_cxn.post_issue({
        "project_id" => default_project_id,
        "subject" => sprintf("%s - %s", newhire_fullname, task.subject),
        "description" => task.long_descr,
        "assigned_to_id" => user_login_to_id(find_role_obj(task.role).user),
        "parent_issue_id" => parent_issue_id,
      })
      all_issue_ids << issue_id
    end

    session[:flash] = [true,
      sprintf("Created issues %s", all_issue_ids.inspect)]
    redirect to("/")
  end

  post("/config") do
    @@db.transaction do
      conf = @@db[:config]
      conf[:default_redmine_proj] = params["default-redmine-proj"]
      conf[:hiring_manager] = params["hiring-manager"]
    end
    session[:flash] = [true, "Successfully updated."]
    redirect to("/")
  end

  post("/tasks") do
    if params["task-name"] =~ EMPTY or params["role-name"] =~ EMPTY
      session[:flash] = [false, "Sorry, please define a role first."]
      redirect to("/")     
    end

    @@db.transaction do
      @@db[:tasks].push(Task.new({
        :subject => params["task-name"],
        :role => params["role-name"],
        :long_descr => params["long-descr"],
      }))
    end

    session[:flash] = [
      true,
      "Task #{params["task-name"].inspect} successfully added."
    ]
    redirect to("/")
  end

  delete("/tasks") do
    @@db.transaction do
      @@db[:tasks].delete_if { |t| t.subject == params["task-name"] }
    end
    session[:flash] = [true,
      "Successfully removed task #{params["task-name"].inspect}."]
    redirect to("/")
  end
end
