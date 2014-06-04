require_relative 'base'

# Common code for the interactive scripts
module TeachersPet
  module Actions
    class Interactive < Base
      def get_auth_method
        auth_method = nil

        choose do |menu|
          menu.prompt = "Login via oAuth or Password? "
          menu.choice :oAuth do
            auth_method = 'oauth'
          end
          menu.choice :Password do
            auth_method = 'password'
          end
        end

        auth_method
      end

      def config_github
        return unless @username.nil?
        @api_endpoint = ask('What is the API endpoint?') { |q| q.default = Configuration.apiEndpoint }
        @web_endpoint = ask("What is the Web endpoint?") { |q| q.default = Configuration.webEndpoint }

        @username = ask('What is your username? (You must be an owner for the organization)?') { |q| q.default = ENV['USER'] }

        @authmethod = self.get_auth_method

        if @authmethod == 'oauth'
            @oauthtoken = ask('What is your oAuth token?') { |q| q.default = ENV['TEACHERS_PET_GITHUB_TOKEN'] }
        end
        if @authmethod == 'password'
            @password = ask('What is your password?') { |q| q.echo = false }
        end
      end

      def read_organization(organization)
        abort("GitHub client not initialized") if @client.nil?
        @client.organization(organization)
      end

      def execute(command)
        `#{command}`
      end


      protected

      def get_students_file_path
        ask("What is the filename of the list of students?") { |q| q.default = TeachersPet::Configuration.studentsFile }
      end

      def get_instructors_file_path
        ask("What is the filename of the list of instructors?") { |q| q.default = TeachersPet::Configuration.instructorsFile }
      end

      def confirm(message, abort_on_no = true)
        # confirm
        confirmed = false
        choose do |menu|
          menu.prompt = message

          menu.choice :yes do confirmed = true end
          menu.choice :no do confirmed = false end
        end
        if abort_on_no && !confirmed
          abort("Creation canceled by user")
        end
        return confirmed
      end
    end
  end
end
