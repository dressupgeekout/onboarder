require 'sinatra/base'
require 'erb'
require 'json'
require 'pstore'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")
require 'redminerest'

class Onboarder < Sinatra::Base
  VERSION = %q(0.2.0a "Sriracha Robot").freeze

  begin # SCOPE
    @@redmine_cxn = nil
    @@db = nil
  end

  configure do
    set :root, File.join(File.dirname(__FILE__), "..", "..")
    set :dbdir, File.join(settings.root, "db")
    enable :sessions
    enable :method_override

    dbfile = File.join(settings.dbdir,
      "onboarder-#{settings.environment}.pstore")

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
