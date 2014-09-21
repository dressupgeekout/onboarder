#!/usr/bin/env ruby
# Onboarder database bootstrap script
require 'pstore'
require 'fileutils'

DBDIR = File.join(File.dirname(__FILE__), "..", "db")
VALID_ENVS = %w[development testing production]

FileUtils.mkdir_p(DBDIR) if not File.directory?(DBDIR)
env = ARGV.shift

if VALID_ENVS.none? { |e| e == env }
  $stderr.puts("Environment must be one of #{VALID_ENVS.inspect}")
  $stderr.puts("Aborting.")
  exit 1
end

dbpath = File.join(DBDIR, "onboarder-#{env}.pstore")

if File.file?(dbpath)
  $stderr.puts("Database file #{File.basename(dbpath).inspect} already exists.")
  $stderr.puts("Aborting.")
  exit 1
end

puts ">> Bootstrapping Onboarder for #{env}."

print "Redmine API Key: "
api_key = $stdin.gets.chomp

print "URI of your Redmine installation: "
uri = $stdin.gets.chomp

db = PStore.new(dbpath)

db.transaction do
  db[:config] = {
    :redmine_api_key => api_key,
    :redmine_uri => uri,
    :hiring_manager => "",
    :default_redmine_proj => "",
  }

  db[:tasks] = []
  db[:roles] = []
end

puts "K, thanks. Database #{File.basename(dbpath).inspect} created."
exit 0
