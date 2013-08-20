#!/usr/bin/ruby

# Author: Mike Helmick - mike.helmick@uc.edu
# Script to create assignment repositories for students under the appropriate organization

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'github_common'

class RepoCreator < GithubCommon

  def initialize()
  end

  def read_info()
    @repository = ask('What repository name should be created for each student?') { |q| q.validate = /\w+/ }
    @organization = ask("What is the organization name?") { |q| q.default = 'CS2-Fall2013' }
    @student_file = ask('What is the name of the list of student IDs') { |q| q.default = 'students' }
    @instructor_file = ask('What is the name of the list of instructor IDs') { |q| q.default = 'instructors' }
  end

  def load_files()
    @students = read_file(@student_file, 'Students')
    @instructors = read_file(@instructor_file, 'Instructors')
  end

  def create
    confirm("Create #{@students.keys.size} repositories for students and give access to instructors?")
    
    # create a repo for each student
    init_client()

    org_hash = read_organization(@organization)
    abort('Organization could not be found') if org_hash.nil?
    puts "Found organization at: #{org_hash[:url]}"

    # we want to list the organization repositories and skip creating ones that already exist
    existing_repos = get_existing_repos_by_names(@organization)

    # Load the teams - there should be one team per student.
    # Repositories are given permissions by teams
    org_teams = get_teams_by_name(@organization)
    # For each student - create a repository, and give permissions to their "team"
    # The repository name is teamName-repository
    puts "\nCreating assignment repositories for students..."
    @students.keys.each do |student|
      unless org_teams.key?(student)
        puts("  ** ERROR ** - no team for #{student}")
        next
      end
      repo_name = "#{student}-#{@repository}"
      
      if existing_repos.key?(repo_name)
        puts " --> Already exists, skipping '#{repo_name}'"
        next
      end
      
      puts " --> Creating '#{repo_name}'"
      @client.create_repository(repo_name,
          {
            :description => "#{@repository} created for #{student}",
            :private => true, ## Current default, repositories are private to the student & instructors
            :has_issues => true, # seems like a resonable default
            :has_wiki => false,
            :has_downloads => false,
            :organization => @organization,
            :team_id => org_teams[student][:id],
            :auto_init => true,
            :gitignore_template => "C++" ## This is specific to my current class, you'll want to change
          })
    end
  end
end

creator = RepoCreator.new
creator.read_info()
creator.load_files()
creator.create()

