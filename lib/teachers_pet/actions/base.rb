require 'active_support/core_ext/hash/keys'
require 'octokit'
require_relative File.join('..', 'configuration')

module TeachersPet
  module Actions
    class Base
      attr_reader :options

      def initialize(opts={})
        @options = opts.symbolize_keys
      end

      def method_missing(meth, *args, &block)
        # Support boolean options ending, by calling them with '?' at the end
        key = meth.to_s.sub(/\?\z/, '').to_sym
        if self.options.has_key?(key)
          self.options[key]
        else
          super
        end
      end

      def init_client
        self.config_github
        puts "=" * 50
        puts "Authenticating to GitHub..."
        Octokit.configure do |c|
          c.api_endpoint = @api_endpoint
          c.web_endpoint = @web_endpoint
          # Organizations can get big, pull in all pages
          c.auto_paginate = true
        end

        case @authmethod
        when 'password'
          @client = Octokit::Client.new(login: @username, password: @password)
        when 'oauth'
          @client = Octokit::Client.new(login: @username, access_token: @oauthtoken)
        end
      end

      def repository?(organization, repo_name)
        begin
          @client.repository("#{organization}/#{repo_name}")
        rescue
          return false
        end
      end

      def get_teams_by_name(organization)
        org_teams = @client.organization_teams(organization)
        teams = Hash.new
        org_teams.each do |team|
          teams[team[:name]] = team
        end
        return teams
      end

      def get_team_member_logins(team_id)
        @client.team_members(team_id).map do |member|
          member[:login]
        end
      end

      def read_file(filename)
        map = Hash.new
        File.open(filename).each_line do |team|
          # Team can be a single user, or a team name and multiple users
          # Trim whitespace, otherwise issues occur
          team.strip!
          items = team.split(' ')
          items.each do |item|
            abort("No users can be named 'owners' (in any case)") if 'owners'.eql?(item.downcase)
          end

          if map[items[0]].nil?
            map[items[0]] = Array.new
            puts " -> #{items[0]}"
            if (items.size > 1)
              print "  \\-> members: "
              1.upto(items.size - 1) do |i|
                print "#{items[i]} "
                map[items[0]] << items[i]
              end
              print "\n"
            else
              map[items[0]] << items[0]
            end
          end
        end

        map
      end

      def read_students_file
        student_file = self.students
        puts "Loading students:"
        read_file(student_file)
      end

      def read_instructors_file
        student_file = self.instructors
        puts "Loading instructors:"
        read_file(student_file)
      end

      def get_auth_method
        options[:token] ? 'oauth' : 'password'
      end

      def config_github
        return unless @username.nil?
        @api_endpoint = options[:api]
        @web_endpoint = options[:web]
        @username = options[:username]
        @authmethod = self.get_auth_method

        case @authmethod
        when 'oauth'
          @oauthtoken = options[:token]
        when 'password'
          @password = options[:password]
        end
      end
    end
  end
end
