#!/usr/bin/env ruby

require 'json'
require 'pstore'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "app")
require 'onboarder/models'

pretty = false
pretty = true if ARGV.include?("--pretty")

db = PStore.new("db/onboarder-development.pstore")

confobj = {
  "roles" => [],
  "tasks" => [],
}

db.transaction do
  fields = %w[redmine_api_key redmine_uri default_redmine_proj hiring_manager]
  fields.each { |field| confobj[field] = db[:config][field.to_sym] }
  db[:roles].each { |role| confobj["roles"].push(role.to_h) }
  db[:tasks].each { |task| confobj["tasks"].push(task.to_h) }
end

output_method = (pretty ? :pretty_generate : :dump)
$stdout.puts(JSON.send(output_method, confobj))
