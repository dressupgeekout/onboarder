#!/usr/bin/env ruby

require 'json'
require 'pstore'
require 'optparse'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "app")
require 'onboarder/models'

def complain(msg, *args)
  $stderr.puts(sprintf(msg, *args))
  exit 1
end

def show_import(msg, *args)
  _args = args.map { |x| x.inspect }
  $stderr.puts(sprintf(msg, *_args))
end

options = {
  :db => nil,
  :input => nil,
  :force => false,
  :verbose => false,
}

parser = OptionParser.new do |opts|
  opts.on("-d", "--db DATABASE") { |db| options[:db] = db }
  opts.on("-i", "--input FILE") { |i| options[:input] = i }
  opts.on("-f", "--force") { options[:force] = true }
  opts.on("-v", "--verbose") { options[:verbose] = true }
end

parser.parse!

complain("You must specify a database.") if options[:db].nil?
complain("You must specify an input file.") if options[:input].nil?

db_realpath = File.expand_path(options[:db])
input_realpath = File.expand_path(options[:input])

if !File.file?(input_realpath)
  complain("There is no file at %s. Aborting.", input_realpath.inspect)
end

if File.file?(db_realpath) and !options[:force]
  complain("There already is a file at %s. Aborting.", db_realpath.inspect)
end

begin
  input_struct = JSON.load(File.read(input_realpath))
rescue JSON::ParserError => err
  complain("Error parsing the JSON input file! %s", err.message)
rescue => err
  complain("Error reading the input file! %s", err.message)
end

db = PStore.new(db_realpath)

db.transaction do
  db[:roles] = [] 
  db[:tasks] = [] 
  db[:taskmaps] = [] 

  input_struct["roles"].each do |role_obj|
    db[:roles].push(Role.new(role_obj))
    show_import("ROLE %s", role_obj["name"]) if options[:verbose]
  end

  input_struct["tasks"].each do |task_obj|
    db[:tasks].push(Task.new(task_obj))
    show_import("TASK %s", task_obj["subject"]) if options[:verbose]
  end

  input_struct["departments"].each do |depot_obj|
    db[:taskmaps].push(TaskMap.new(depot_obj))
    show_import("DEPARTMENT %s", depot_obj["name"]) if options[:verbose]
  end
end

if options[:verbose]
  $stderr.puts(sprintf"Imported %s to new database %s", input_realpath,
    db_realpath)
end

exit 0
