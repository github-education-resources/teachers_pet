require 'csv'
require 'json'
require 'webmock/rspec'

require_relative File.join('..', 'lib', 'teachers_pet')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end


def stub_get_json(url, response)
  stub_request(:get, url).to_return(
    headers: {
      'Content-Type' => 'application/json'
    },
    body: response.to_json
  )
end

def students_list_fixture_path
  File.join(File.dirname(__FILE__), 'fixtures', 'students.csv')
end

def student_usernames
  CSV.read(students_list_fixture_path).flatten
end

def student_teams
  student_usernames.each_with_index.map do |username, i|
    {
      url: "https://api.github.com/teams/#{i}",
      name: username,
      id: i
    }
  end
end
