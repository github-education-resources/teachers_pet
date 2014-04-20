# Configuration for the edugit scripts. Modify this as desired to change
# your defaults in the prompts
module TeachersPet
  class Configuration

    # For github.com: 'https://api.github.com/'
    # For GitHub Enterprise: 'https://yourServer.com/api/v3'
    @@API_ENDPOINT = 'https://api.github.com/'

    def self.apiEndpoint
      @@API_ENDPOINT
    end

    # For github.com: https://www.github.com/'
    # For GitHub Enterprise: ''https://yourServer.com/'
    @@WEB_ENDPOINT = 'https://www.github.com/'

    def self.webEndpoint
      @@WEB_ENDPOINT
    end

    # The name of your organization
    @@ORGANIZATION = 'edugit-test'

    def self.organization
      @@ORGANIZATION
    end

    # The name fo the file that contains the team definitions / students
    @@STUDENTS_FILE = 'students'

    def self.studentsFile
      @@STUDENTS_FILE
    end

    # The name of the file that contains the GitHub usernames of the instructors
    @@INSTRUCTORS_FILE = 'instructors'

    def self.instructorsFile
      @@INSTRUCTORS_FILE
    end

    # The default is to create the repositories as public.
    # If you are using GitHub enterprise or a paid account, it make sense to make this private
    @@REPOS_PUBLIC = true

    def self.reposPublic
      @@REPOS_PUBLIC
    end

    # github.com - set to 'github.com'
    # GitHub Enterprise - 'yourserver.com'
    @@SSH_ENDPOINT = 'github.com'

    def self.sshEndpoint
      @@SSH_ENDPOINT
    end

    ## It is best to push remotes vis SSH, you can swith this to false to push as HTTPS
    @@REMOTE_SSH = true

    def self.remoteSsh
      @@REMOTE_SSH
    end

  end
end
