require 'octokit'
require_relative File.join('..', 'configuration')

## Common code for the edugit scripts.
module TeachersPet
  module Actions
    class Base
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
          @client = Octokit::Client.new(:login => @username, :password => @password)
        when 'oauth'
          @client = Octokit::Client.new(:login => @username, :access_token => @oauthtoken)
        end
      end
    end
  end
end
