require 'thor'
require_relative 'actions/fork_collab'

module TeachersPet
  class Cli < Thor
    def self.common_options
      option :username, default: ENV['USER']
      option :password
      option :token, default: ENV['TEACHERS_PET_GITHUB_TOKEN'], desc: "Provide a token instead of a username+password to authenticate via OAuth. See https://github.com/education/teachers_pet#authentication."

      option :api, default: Configuration.apiEndpoint, desc: "The API endpoint of your GitHub Enterprise instance, if you have one."
      option :web, default: Configuration.webEndpoint, desc: "The URL of your GitHub Enterprise instance, if you have one."
    end


    # TODO figure out a way to display options as groups

    option :repository, required: true, banner: 'OWNER/REPO'
    option :dry_run, type: :boolean
    common_options
    desc "fork_collab", "Give collaborator access to everyone who has forked a particular repository."
    def fork_collab
      TeachersPet::Actions::ForkCollab.new(options).run
    end


    option :organization, default: TeachersPet::Configuration.organization
    option :repository, required: true

    option :title, desc: "The title of the issue to be created"
    option :body, banner: 'PATH', desc: "The path to the file containing the issue body (.txt or .md)"
    option :labels, banner: 'LABEL1,LABEL2'

    option :students, default: TeachersPet::Configuration.studentsFile, banner: 'PATH', desc: "The path to the file containing the list of students"
    option :instructors, default: TeachersPet::Configuration.instructorsFile, banner: 'PATH', desc: "The path to the file containing the list of instructors"

    common_options

    desc "open_issue", "Opens a single issue in each repository in the organization."
    def open_issue
      TeachersPet::Actions::OpenIssue.new(options).run
    end
  end
end
