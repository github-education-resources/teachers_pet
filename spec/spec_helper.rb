require 'simplecov'
SimpleCov.start do
  add_group 'Actions' do |src_file|
    file = src_file.filename
    file.include?(File.join('lib', 'teachers_pet', 'actions')) && File.basename(file) != 'base.rb'
  end
  add_group 'Commands', '/lib/teachers_pet/commands/'
  add_group 'Specs', '/spec/'
end

require 'active_support/core_ext/hash/keys'
require 'csv'
require 'json'
require 'webmock/rspec'

require_relative File.join('..', 'lib', 'teachers_pet')
require_rel 'support'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include CommonHelpers
end
