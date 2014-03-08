#!/usr/bin/ruby

$LOAD_PATH << File.dirname(__FILE__)

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'github_common'
require 'config'

# This script should be run within a working directory that is a git repository.
# It will add a remote that is the name of each student team to your repository

class PushFiles < GithubCommon
  def initalize
  end

  def read_info
    @repository = ask('What repository name should pushed to for each student?') { |q| q.validate = /\w+/ }
    
    @organization = ask("What is the organization name?") { |q| q.default = Configuration.organization }
    @student_file = ask('What is the name of the list of student IDs') { |q| q.default = Configuration.studentsFile }
    @sshEndpoint = ask('What is the ssh endpoint?') { |q| q.default = Configuration.sshEndpoint }
  end

  def load_files
    @students = read_file(@student_file, 'Students')
  end

  def push
    confirm("Push files to student repositories?")
    init_client()

    org_hash = read_organization(@organization)
    abort('Organization could not be found') if org_hash.nil?
    puts "Found organization at: #{org_hash[:url]}"

    # Load the teams - there should be one team per student.
    # Repositories are given permissions by teams
    org_teams = get_teams_by_name(@organization)

    # For each student - if an appropraite repository exists,
    # add it to the list.
    remotes_to_add = Hash.new
    @students.keys.sort.each do |student|
      unless org_teams.key?(student)
        puts("  ** ERROR ** - no team for #{student}")
        next
      end
      repo_name = "#{student}-#{@repository}"
      
      unless repository?(@organization, repo_name)
        puts("  ** ERROR ** - no repository called #{repo_name}")
      end
      if Configuration.remoteSsh
        remotes_to_add[student] = "git@#{@sshEndpoint}:#{@organization}/#{repo_name}.git"
      else
        remotes_to_add[student] = "#{@web_endpoint}#{@organization}/#{repo_name}.git"
      end
    end

    puts "Adding remotes and pushing files to student repositories."
    remotes_to_add.keys.each do |remote|
      puts "#{remote} --> #{remotes_to_add[remote]}"
      `git remote add #{remote} #{remotes_to_add[remote]}`
      `git push #{remote} master`
    end
  end
end

pusher = PushFiles.new
pusher.read_info()
pusher.load_files()
pusher.push()