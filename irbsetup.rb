require 'virtus'
require 'pstore'
require_relative 'app/onboarder/models' 
$stderr.puts("The database is available as `@d'")
@d = PStore.new("./db/onboarder-development.pstore")
