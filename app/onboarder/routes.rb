class Onboarder
  EMPTY = /\A\s*\z/

  get("/") do
    erb(:index)
  end

  get("/attachments/?") do
    erb(:attachments)
  end

  post("/attachments") do
    status(501)
    return
  end

  post("/roles") do
    if params["role-name"] =~ EMPTY
      set_flash_failure("Sorry, please enter a nonblank name.")
      return redirect to("/")
    end

    @@db.transaction do
      @@db[:roles].push(Role.new({
        :name => params["role-name"],
        :user => params["user"],
      }))
    end

    set_flash_success(sprintf("Successfully assigned %s as the %s.",
      user_login_to_pretty(params["user"]), params["role-name"]))

    redirect to("/")
  end

  delete("/roles") do
    if task_map.any? { |t| t.role == params["role-name"] }
      status(403)
      set_flash_failure(sprintf(
        "Please remove all of the tasks assigned to the %s role, first.",
        params["role-name"].inspect))
      redirect to("/")
    end

    @@db.transaction do
      @@db[:roles].delete_if { |r| r.name == params["role-name"] }
    end

    set_flash_success(sprintf(
      "Successfully removed the %s role.", params["role-name"].inspect))
    redirect to("/")
  end

  post("/newhire") do
    name_fields = [params["newhire-name-first"], params["newhire-name-last"]]
    date_fields = [params["newhire-startdate-year"],
      params["newhire-startdate-month"], params["newhire-startdate-day"]]

    if name_fields.any? { |n| n =~ EMPTY }
      set_flash_failure("Sorry, please enter a nonblank name.")
      status(403)
      return erb(:index)
    end

    if params["newhire-klass"] =~ EMPTY
      set_flash_failure("Sorry, please specify an employee class.")
      status(403)
      return erb(:index)
    end

    if date_fields.any? { |d| d =~ EMPTY }
      set_flash_failure("Sorry, please enter a valid date.")
      status(403)
      return erb(:index)
    end

    begin
      if Time.new(*(date_fields.map { |x| x.to_i })) < Time.now
        set_flash_failure("Sorry, you must enter a date in the future.")
        status(403)
        return erb(:index)
      end
    rescue ArgumentError
      set_flash_failure("Sorry, please enter a valid date.")
      status(403)
      return erb(:index)
    end

    if !config(:default_redmine_proj) or config(:default_redmine_proj).empty?
      set_flash_failure(%q(
        Sorry, please define the Redmine project.
        <a href="#configuration">Click here.</a>
      ))
      status(403)
      return erb(:index)
    end

    if !config(:hiring_manager) or config(:hiring_manager).empty?
      set_flash_failure("Sorry, please establish the hiring manager.")
      status(403)
      return erb(:index)
    end

    if !task_map or task_map.empty?
      set_flash_failure("Sorry, please define at least one task.")
      status(403)
      return erb(:index)
    end

    if !all_roles or all_roles.empty?
      set_flash_failure("Sorry, please define at least one role.")
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
      "due_date" => sprintf("%04d-%02d-%02d", *date_fields),
    })

    all_issue_ids = []
    all_issue_ids << parent_issue_id

    relevant_task_subjects = tasks_from_name(params["newhire-klass"])
    relevant_tasks = task_map.select { |t|
      relevant_task_subjects.include?(t.subject)
    }

    # Now post all of the "real" issues
    relevant_tasks.each do |task|
      issue_id = @@redmine_cxn.post_issue({
        "project_id" => default_project_id,
        "subject" => sprintf("%s - %s", newhire_fullname, task.subject),
        "description" => task.long_descr,
        "assigned_to_id" => user_login_to_id(find_role_obj(task.role).user),
        "parent_issue_id" => parent_issue_id,
        "due_date" => sprintf("%04d-%02d-%02d", *date_fields),
      })
      all_issue_ids << issue_id
    end

    set_flash_success(sprintf("Created issues %s", all_issue_ids.inspect))
    redirect to("/")
  end

  get("/config/?") do
    erb(:configuration)
  end

  post("/config") do
    @@db.transaction do
      conf = @@db[:config]
      conf[:default_redmine_proj] = params["default-redmine-proj"]
      conf[:hiring_manager] = params["hiring-manager"]
    end
    set_flash_success("Successfully updated.")
    redirect to("/config")
  end

  post("/tasks") do
    if params["task-name"] =~ EMPTY or params["role-name"] =~ EMPTY
      set_flash_failure("Sorry, please define a role first.")
      return erb(:"task_table")
    end

    @@db.transaction do
      @@db[:tasks].push(Task.new({
        :subject => params["task-name"],
        :role => params["role-name"],
        :long_descr => params["long-descr"],
      }))
    end

    set_flash_success(sprintf(
      "Task %s successfully added to the task map.",
      params["task-name"].inspect))
    redirect to("/tasktable")
  end

  delete("/tasks") do
    @@db.transaction do
      @@db[:tasks].delete_if { |t| t.subject == params["task-name"] }
    end

    set_flash_success(sprintf(
      "Successfully removed task %s from the task map.",
      params["task-name"].inspect))
    redirect to("/tasktable")
  end

  post("/taskmaps") do
    if params["taskmap-name"] =~ EMPTY
      set_flash_failure("Sorry, please enter a nonblank name.")
      status(403)
      return erb(:index)
    end

    @@db.transaction do
      tm = TaskMap.new({:name => params["taskmap-name"]})
      @@db[:taskmaps].push(tm)
    end

    redirect to("/")
  end

  delete("/taskmaps") do
    status(501)
    return
  end

  get("/tasktable/?") do
    erb(:task_table)
  end

  # Currently, the strategy is to clear the entire list of tasks for each
  # class of employee, then re-populate it according to the HTML form.
  post("/tasktable") do
    @@db.transaction do
      @@db[:taskmaps].each { |tm| tm.tasks = [] }
      request.POST.each do |thang, _|
        split = thang.split("-", 2)
        tm_name = split[0]
        subject = split[1]
        tm = @@db[:taskmaps].detect { |t| t.name == tm_name }
        tm ? tm.tasks.push(subject) : next
      end
    end

    status(200)
    set_flash_success("Task table updated successfully.")
    return erb(:task_table)
  end
end
