require 'simplecov'
SimpleCov.start do
  add_group 'Actions' do |src_file|
    file = src_file.filename
    file.include?('/lib/teachers_pet/actions/') && !file.end_with?('/base.rb')
  end
  add_group 'Specs', '/spec/'
end

require 'csv'
require 'json'
require 'webmock/rspec'

require_relative File.join('..', 'lib', 'teachers_pet')

RSpec.configure do |config|
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
  File.join(File.dirname(__FILE__), 'fixtures', 'students')
end

def instructors_list_fixture_path
  File.join(File.dirname(__FILE__), 'fixtures', 'instructors')
end

def issue_fixture_path
  File.join(File.dirname(__FILE__), 'fixtures', 'issue.md')
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

def respond(question, response)
  allow(action).to receive(:ask).with(question).and_return(response)
end

def confirm(question, response)
  allow(action).to receive(:confirm).with(question, false).and_return(response)
end

def stub_github_config
  respond("What is the API endpoint?", TeachersPet::Configuration.apiEndpoint)
  respond("What is the Web endpoint?", TeachersPet::Configuration.webEndpoint)
  respond("What is your username? (You must be an owner for the organization)?", 'testteacher')
  allow(action).to receive(:get_auth_method) { 'password' }
  respond("What is your password?", 'abc123')
end
