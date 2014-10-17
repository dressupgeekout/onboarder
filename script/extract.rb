#!/usr/bin/env ruby

require 'json'
require 'pstore'
require 'optparse'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "app")
require 'onboarder/models'

def complain(msg)
  $stderr.puts(msg)
  exit 1
end

options = {
  :pretty => false,
  :db => nil,
}

parser = OptionParser.new do |opts|
  opts.on("-p", "--pretty") { options[:pretty] = true }
  opts.on("-d", "--db DATABASE") { |db| options[:db] = db }
end

parser.parse!

if options[:db].nil? or !File.file?(File.expand_path(options[:db]))
  complain("No such file: %s", options[:db].inspect)
end

confobj = {
  "roles" => [],
  "tasks" => [],
  "departments" => [],
}

db = PStore.new(options[:db])

db.transaction do
  fields = %w[redmine_api_key redmine_uri default_redmine_proj hiring_manager]
  fields.each { |field| confobj[field] = db[:config][field.to_sym] }
  db[:roles].each { |role| confobj["roles"].push(role.to_h) }
  db[:tasks].each { |task| confobj["tasks"].push(task.to_h) }
  db[:taskmaps].each { |taskmap| confobj["departments"].push(taskmap.to_h) }
end

output_method = (options[:pretty] ? :pretty_generate : :dump)
$stdout.puts(JSON.send(output_method, confobj))
