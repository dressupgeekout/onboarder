require 'virtus'

# The Role is an abstraction of a User.
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
