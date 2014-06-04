require 'thor'
require_relative 'actions/fork_collab'

module TeachersPet
  class Cli < Thor
    # TODO figure out a way to display options as groups

    option :repository, required: true

    option :oauth, type: :boolean
    option :username, default: ENV['USER']
    option :password
    option :token

    option :api, default: Configuration.apiEndpoint
    option :web, default: Configuration.webEndpoint

    desc "fork_collab", "Give collaborator access to everyone who has forked a particular repository."
    def fork_collab
      TeachersPet::Actions::ForkCollab.new(options).run
    end
  end
end
