require 'thor'
require_relative 'actions/fork_collab'

module TeachersPet
  class Cli < Thor
    # TODO figure out a way to display options as groups

    option :repository, required: true, banner: 'OWNER/REPO'

    option :oauth, type: :boolean, desc: "Use token authentication, instead of a username + password. See https://github.com/education/teachers_pet#authentication for more info."
    option :username, default: ENV['USER']
    option :password
    option :token

    option :api, default: Configuration.apiEndpoint, desc: "The API endpoint of your GitHub Enterprise instance, if you have one."
    option :web, default: Configuration.webEndpoint, desc: "The URL of your GitHub Enterprise instance, if you have one."

    desc "fork_collab", "Give collaborator access to everyone who has forked a particular repository."
    def fork_collab
      if options['oauth']
        unless options['token']
          raise RequiredArgumentMissingError.new("'--token' required when using OAuth")
        end
      else # basic auth
        unless options['username']
          raise RequiredArgumentMissingError.new("'--username' required when using basic auth")
        end

        unless options['password']
          raise RequiredArgumentMissingError.new("'--password' required when using basic auth")
        end
      end

      TeachersPet::Actions::ForkCollab.new(options).run
    end
  end
end
