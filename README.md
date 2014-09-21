# Onboarder

We use [Redmine][] to manage our to-do lists for nearly everything at [Norse
Corp][], including all the tasks that are required for getting new hires up
to speed. We identified a whole bunch of boilerplate with respect to new
hires, as well as a need to better streamline this process in general.

That's what this project is all about. **Onboarder** is a simple web app --
essentially, a frontend to Redmine -- that automatically sets up tickets for
the appropriate people for the appropriate tasks. It's the tool your HR
department never knew it really needed.

The Onboarder tool is primarily developed at Norse Corp, but it's generic
enough (and open-source enough) to be used at your workplace, too! A simple
configuration file takes care of all the gory details.


## The Configuration File

Onboarder expects a configuration file -- which must consist of one valid
JSON object -- inside a file "config.json".

  - `"redmine_api_key"`: Your Redmine API key. You can find this inside the
    "My account" page inside your Redmine installation.

  - `"redmine_uri"`: The URI to your installation of Redmine.

  - `"redmine_default_project"`: The name of the Redmine project under which
    these onboarding tickets will be created.

The `"task_map"` subobject is a mapping from Redmine ID to a list of tasks.

## System Requirements

Onboarder is written in Ruby against the Sinatra framework, so you need a
Rack-complaint HTTP server. It requires Ruby 1.9 or greater
(`require_relative` shows up a few times). And of course, you must have an
installation of Redmine up and running, too.


## License

Onboarder is released under a 2-clause BSD-style license. Refer to the
LICENSE document for details.


[Redmine]: http://redmine.org
[Norse Corp]: https://norse-corp.com
