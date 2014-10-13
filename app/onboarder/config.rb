require 'sinatra/base'
require 'erb'
require 'json'
require 'pstore'
require 'fileutils'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
require 'redminerest'

class Onboarder < Sinatra::Base
  VERSION = %q(0.1.0a "I'm the Map")

  begin # SCOPE
    @@redmine_cxn = nil
    @@db = nil
  end

  configure do
    set :root, File.join(File.dirname(__FILE__), "..", "..")
    set :dbdir, File.join(settings.root, "db")
    set :uploaddir, File.join(settings.root, "upload")
    enable :sessions
    enable :method_override

    dbfile = File.join(settings.dbdir,
      "onboarder-#{settings.environment}.pstore")

    if not File.directory?(settings.uploaddir)
      FileUtils.mkdir_p(settings.uploaddir)
    end

    if !File.file?(dbfile)
      $stderr.puts("Cannot find the database. Please bootstrap it.")
      $stderr.puts("Aborting.")
      exit 1
    end

    @@db = PStore.new(dbfile)
    uri, api_key = nil, nil

    @@db.transaction do
      api_key = @@db[:config][:redmine_api_key]
      uri = @@db[:config][:redmine_uri]
    end

    @@redmine_cxn = RedmineRest.new(uri, api_key)
  end

  before do
    response["Content-Type"] = "text/html;charset=utf-8"
  end
end
