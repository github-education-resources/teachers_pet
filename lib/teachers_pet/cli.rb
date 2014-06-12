require 'thor'

module TeachersPet
  class Cli < Thor
    # TODO figure out a way to display options as groups

    def self.common_options
      option :username, default: ENV['USER']
      option :password
      option :token, default: ENV['TEACHERS_PET_GITHUB_TOKEN'], desc: "Provide a token instead of a username+password to authenticate via OAuth. See https://github.com/education/teachers_pet#authentication."

      option :api, banner: 'ORIGIN', default: Configuration.apiEndpoint, desc: "The API endpoint of your GitHub Enterprise instance, if you have one."
      option :web, banner: 'ORIGIN', default: Configuration.webEndpoint, desc: "The URL of your GitHub Enterprise instance, if you have one."
    end

    def self.students_option
      option :students, default: TeachersPet::Configuration.studentsFile, banner: 'PATH', desc: "The path to the file containing the list of students"
    end
  end
end
