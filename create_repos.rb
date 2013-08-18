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
  end
end

creator = RepoCreator.new
creator.read_info()
creator.load_files()
creator.create()

