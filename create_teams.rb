#!/usr/bin/ruby

# Author: Mike Helmick
# Creates "teams" for an origanization. In this scenario - each team consists of
# one student, and any instructors for the course.

# The students and instructors files contain 1 userid per line.
#  - For teams, the students file should be "teamName studentName studentName"
# We recommend that instructors also be created as students for ease of testing.

$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'github_common'
require 'config'

class TeamCreator < GithubCommon

  def initialize
  end

  def read_info
    @organization = ask("What is the organization name?") { |q| q.default = Configuration.organization }
    @student_file = ask('What is the name of the list of student IDs') { |q| q.default = Configuration.studentsFile }
    @instructor_file = ask('What is the name of the list of instructor IDs') { |q| q.default = Configuration.instructorsFile }
  end

  def load_files
    @students = read_file(@student_file, 'Students')
    @instructors = read_file(@instructor_file, 'Instructors')
  end

  def create
    init_client()
    confirm("Create teams for #{@students.size} students/teams?")

    existing = Hash.new
    teams = @client.organization_teams(@organization)
    teams.each { |team| existing[team[:name]] = team }

    puts "\nDetermining which students need teams created..."
    todo = Hash.new
    @students.keys.each do |team|
      if existing[team].nil?
        puts " -> #{team}"
        todo[team] = true
      end
    end

    if todo.empty?
      puts "\nAll teams exist"
    else
      puts "\nCreating team..."
      todo.keys.each do |team|
        puts " -> '#{team}' ..."
        @client.create_team(@organization,
            {
              :name => team,
              :permission => 'push'
            })
      end
    end

    puts "\nAdjusting team memberships"
    teams = @client.organization_teams(@organization)
    teams.each do |team|
      team_members = get_team_members(team[:id])
      if team[:name].eql?('Owners')
        puts "*** OWNERS *** - Ensuring instructors are owners"
        @instructors.keys.each do |instructor|
          unless team_members.key?(instructor)
            @client.add_team_member(team[:id], instructor)
            puts " -> '#{instructor}' has been made an owner for this course"
          else
            puts " -> '#{instructor}' is already an owner"
          end
        end
      elsif @students.key?(team[:name])
        puts "Validating membership for team '#{team[:name]}'"
        # If there isn't a team member that is the same name as the team, and we already know
        # there is a student with the same name, add that student to the team.
        #unless team_members.key?(team[:name])
        @students[team[:name]].each do |student|
          puts "  -> Adding '#{team[:name]}' to the team"
          @client.add_team_member(team[:id], student)
        end
        # Originally, instructors were added to the student's team, but that isn't needed
        # since instructors are addded to the Owners team that can see all repositories.
      else
        puts "*** Team name '#{team[:name]}' does not match any students, ignoring. ***"
      end
    end
  end
end

creator = TeamCreator.new
creator.read_info()
creator.load_files()
creator.create()