class Onboarder
  helpers do
    def truncate(str, len=35)
      return str if str.length <= len
      return str[0, len] + "..."
    end

    def config(item)
      return @@db.transaction { @@db[:config][item] }
    end

    def all_roles()
      return @@db.transaction { @@db[:roles] }.sort
    end

    # Returns the numeric ID of the Redmine project under which onboarding
    # tickets will be filed.
    def default_project_id()
      return @@redmine_cxn.all_projects.
        detect { |pr| pr["identifier"] == config(:default_redmine_proj) }.
        fetch("id").to_i
    end

    def redmine_server_uri()
      return @@redmine_cxn.server_uri
    end

    # Returns a list User objects for every user in Redmine. This here is
    # why the API key associated with Onboarder needs to be for a Redmine
    # administrator.
    def all_redmine_users()
      return @@redmine_cxn.all_users
    end

    def redmine_login_to_real_name_link(login)
      user = all_redmine_users.detect { |user| user["login"] == login }
      return sprintf('<a href="%s/users/%d">%s %s</a>',
        redmine_server_uri, user["id"], user["firstname"], user["lastname"])
    end

    def all_redmine_projects()
      return @@redmine_cxn.all_projects
    end

    def all_taskmaps()
      return @@db.transaction { @@db[:taskmaps] }.sort
    end

    def task_map()
      return @@db.transaction { @@db[:tasks] }.sort
    end

    def user_from_login(login)
      return all_redmine_users.detect { |u| u["login"] == login }
    end

    def user_login_to_pretty(login)
      user = user_from_login(login)
      return sprintf("%s %s (\"%s\")", user["firstname"], user["lastname"],
        login)
    end

    # Returns the Role object with the given Role @name.
    def find_role_obj(name)
      @@db.transaction { @@db[:roles].detect { |r| r.name == name }}
    end

    # Given a user's login name, return his or her numeric ID.
    def user_login_to_id(login)
      user = user_from_login(login)
      return user["id"]
    end

    def tasks_from_name(name)
      tm = \
        @@db.transaction { @@db[:taskmaps].detect { |tm| tm.name == name }}
      return tm.tasks
    end

    # This returns a blob of HTML: a <select> element with a bunch of
    # <options> which refers to everyone inside Redmine. 
    #
    # `id` refers to the "id" and the "name" HTML attribute. The selection
    # will display the user with the `selected` login name if it is
    # provided. The form will see the user's login attribute.
    def select_any_redmine_user(id, selected=nil)
      templ = <<-EOF
        <select name="<%= id %>" id="<%= id %>">
          <% all_redmine_users.each do |user| %>
            <option
              value="<%= user["login"] %>"
              <%= "selected" if user["login"] == selected %>
            >
              <%= user_login_to_pretty(user["login"]) %>
            </option>
          <% end %>
        </select>
      EOF
      return ERB.new(templ, nil, "<>").result(binding)
    end

    # The form will see the role's name.
    def select_any_role(id, selected=nil)
      templ = <<-EOF
        <select name="<%= id %>" id="<%= id %>">
          <% all_roles.each do |role| %>
            <option
              value="<%= role.name %>"
              <%= "selected" if role.name == selected %>
            >
              <%= role.name %> &mdash;
              <%= user_login_to_pretty(role.user) %>
            </option>
          <% end %>
        </select>
      EOF
      return ERB.new(templ, nil, "<>").result(binding)
    end

    # Renders a HTML <select> element with the provided "name" attribute.
    def select_any_taskmap(name)
      templ = <<-EOF
        <select name="<%= name %>">
          <% all_taskmaps.each do |taskmap| %>
            <option value="<%= taskmap.name %>"><%= taskmap.name %></option>
          <% end %>
        </select>
      EOF
      return ERB.new(templ, nil, "<>").result(binding)
    end

    def select_some_tasks(form_id)
      templ = <<-EOF
        <ul style="margin:0em; padding:0em;">
          <% task_map.each do |mapping| %>
            <li style="list-style:none;">
              <input
                form="<%= form_id %>" type="checkbox" name="x" value="y"
                <% if true %>checked<% end %>
              />
              <label><%= mapping.subject %></label>
            </li>
          <% end %>
        </ul>
      EOF
      return ERB.new(templ, nil, "<>").result(binding)
    end

    # This actually sets the session variable.
    def set_flash_success(msg)
      session[:flash] = [true, msg]
    end

    # This actually sets the session variable.
    def set_flash_failure(msg)
      session[:flash] = [false, msg]
    end

    # This method returns the HTML for displaying a flash message.
    def flash(msg, success=true)
      if success
        return sprintf(%q(<span class="flash flash-success">%s</span>), msg)
      else
        return sprintf(%q(<span class="flash flash-fail">%s</span>), msg)
      end
    end
  end
end
