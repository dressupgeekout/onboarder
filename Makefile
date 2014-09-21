.PHONY:	dependencies server dbdump bootstrap testrest irb

# Set to "production" when you're ready
RACK_ENV= development

BUNDLER= bundle exec
RACKUP= rackup

dependencies:
	mkdir -p vendor
	bundle install --path vendor/bundle

bootstrap:
	./script/bootstrap.rb $(RACK_ENV)

server:
	RACK_ENV=$(RACK_ENV) $(BUNDLER) $(RACKUP)

dbdump:
	@$(BUNDLER) ruby -rpstore -r./app/onboarder/models \
		-e 'd=PStore.new("./db/onboarder-development.pstore")' \
		-e 'd.transaction { d.roots.each { |r| puts r.inspect; p d[r]; puts }}'

irb:
	$(BUNDLER) irb -r./irbsetup
