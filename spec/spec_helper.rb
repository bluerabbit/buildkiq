$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "buildkiq"

RSpec.configure do |c|
  c.filter_run_excluding aws: true
end
