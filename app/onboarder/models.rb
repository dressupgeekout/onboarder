require 'virtus'

# The Role is an abstraction of a Redmine user.
class Role
  include Virtus.model
  include Comparable
  attribute :name, String
  attribute :user, String

  def <=>(other)
    if self.name < other.name
      return -1
    elsif self.name > other.name
      return 1
    else
      return 0
    end
  end

  def to_h
    return {"name" => @name, "user" => @user,}
  end
end

# A Task is assigned to the user who fulfills a certain Role.
class Task
  include Virtus.model
  include Comparable
  attribute :subject, String
  attribute :role, String
  attribute :long_descr, String

  def <=>(other)
    if self.subject < other.subject
      return -1
    elsif self.subject > other.subject
      return 1
    else
      return 0
    end
  end

  def to_h
    return {
      "subject" => @subject,
      "role" => @role,
      "long_descr" => @long_descr,
    }
  end
end

# A TaskMap represents the list of tasks that are necessary for a certain
# class of employee. For example, engineers have different onboarding
# requirements from sales people.
#
# The @tasks attribute represents a list of Task objects, which are
# identified here by their @subject attribute.
class TaskMap
  include Virtus.model
  include Comparable
  attribute :name, String
  attribute :tasks, Array[String]

  def <=>(other)
    if self.name < other.name
      return -1
    elsif self.name > other.name
      return 1
    else
      return 0
    end
  end

  def to_h
    return {"name" => @name, "tasks" => @tasks}
  end
end
