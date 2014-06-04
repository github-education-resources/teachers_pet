require 'thor'
require_relative 'actions/fork_collab'

module TeachersPet
  class Cli < Thor
    # TODO figure out a way to display options as groups

    option :repository, required: true, banner: 'OWNER/REPO'

    option :username, default: ENV['USER']
    option :password
    option :token, desc: "Provide a token instead of a username+password to authenticate via OAuth. See https://github.com/education/teachers_pet#authentication."

    option :api, default: Configuration.apiEndpoint, desc: "The API endpoint of your GitHub Enterprise instance, if you have one."
    option :web, default: Configuration.webEndpoint, desc: "The URL of your GitHub Enterprise instance, if you have one."

    option :dry_run, type: :boolean

    desc "fork_collab", "Give collaborator access to everyone who has forked a particular repository."
    def fork_collab
      TeachersPet::Actions::ForkCollab.new(options).run
    end
  end
end
