$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'configuration'

## Common code for the edugit scripts.
module TeachersPet
  module Actions
    class Base
      def config_githib
        return unless @username.nil?
        @api_endpoint = ask('What is the API endpoint?') { |q| q.default = Configuration.apiEndpoint }
        @web_endpoint = ask("What is the Web endpoint?") { |q| q.default = Configuration.webEndpoint }

        @username = ask('What is your username? (You must be an owner for the organization)?') { |q| q.default = ENV['USER'] }

        choose do |menu|
          menu.prompt = "Login via oAuth or Password? "
          menu.choice :oAuth do
            @authmethod = 'oauth'
          end
          menu.choice :Password do
            @authmethod = 'password'
          end
        end

        if @authmethod == 'oauth'
            @oauthtoken = ask('What is your oAuth token?') { |q| q.default = ENV['ghe_oauth'] }
        end
        if @authmethod == 'password'
            @password = ask('What is your password?') { |q| q.echo = false }
        end
      end

      def init_client
        self.config_githib
        puts "=" * 50
        puts "Authenticating to github..."
        Octokit.configure do |c|
          c.api_endpoint = @api_endpoint
          c.web_endpoint = @web_endpoint
          # Organizations can get big, pull in all pages
          c.auto_paginate = true
        end

        if @authmethod == 'password'
          @client = Octokit::Client.new(:login => @username, :password => @password)
        end
        if @authmethod == 'oauth'
          @client = Octokit::Client.new(:login => @username, :access_token => @oauthtoken)
        end
      end

      def read_organization(organization)
        abort("Githib client not initialized") if @client.nil?
        @client.organization(organization)
      end

      protected
      def repository?(organization, repo_name)
        begin
          @client.repository("#{organization}/#{repo_name}")
        rescue
          return false
        end
      end

      def get_existing_repos_by_names(organization)
        repos = Hash.new
        response = @client.organization_repositories(organization)
        print " Org repo names"
        response.each do |repo|
          repos[repo[:name]] = repo
          print " '#{repo[:name]}'"
        end
        print "\n";
        return repos
      end

      def get_teams_by_name(organization)
        org_teams = @client.organization_teams(organization)
        teams = Hash.new
        org_teams.each do |team|
          teams[team[:name]] = team
        end
        return teams
      end

      def get_team_members(team_id)
        team_members = Hash.new
        @client.team_members(team_id).each do |member|
          team_members[member[:login]] = member
        end
        return team_members
      end

      def read_file(filename, type)
        map = Hash.new
        puts "Loading #{type}:"
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
        return map
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
