require 'net/http'
require 'uri'
require 'json'

# This class implements a convenient interface to a variety of HTTP REST
# calls to an installation of Redmine.
class RedmineRest
  attr_reader :server_uri

  def initialize(server_uri, api_key)
    @server_uri = URI(server_uri)
    @api_key = api_key
  end

  def add_ticket(who)
    setup_post
  end

  # => (Array of Hash)
  # XXX You can't do this unless you're a Redmine admin :(
  def all_users()
    @endpoint = "/users.json"
    setup_get
    res = @http.request(@req)
    return JSON.load(res.body)["users"].sort_by { |user| user["lastname"] }
  end

  # => (Array of Hash)
  def all_projects()
    @endpoint = "/projects.json"
    setup_get
    res = @http.request(@req)
    return JSON.load(res.body)["projects"].sort_by { |proj| proj["name"] }
  end

  # => (Array of Hash)
  def all_issues()
    @endpoint = "/issues.json"
    setup_get
    res = @http.request(@req)
    return JSON.load(res.body)["issues"].sort_by { |issue| issue["id"] }
  end

  # The structure of the issue_obj Hash is specified here:
  #     http://www.redmine.org/projects/redmine/wiki/Rest_Issues
  #
  # Returns the ID of the newly created issue.
  def post_issue(issue_obj)
    @endpoint = "/issues.json"
    setup_post
    @req_obj = {"issue" => issue_obj}
    req_obj_to_json_body
    res = @http.request(@req)
    return JSON.load(res.body)["issue"]["id"]
  end

  private

  def setup
    @http = Net::HTTP.start(@server_uri.host, @server_uri.port)
  end

  def auth
    @req["X-Redmine-API-Key"] = @api_key
  end

  def setup_get
    setup
    @req = Net::HTTP::Get.new(@endpoint)
    auth
  end

  def setup_post
    setup
    @req = Net::HTTP::Post.new(@endpoint)
    @req["Content-Type"] = "application/json"
    @req.content_type = "application/json"
    auth
  end

  def req_obj_to_json_body
    j = JSON.dump(@req_obj)
    @req.body = j
    @req["Content-Length"] = j.length
  end
end
