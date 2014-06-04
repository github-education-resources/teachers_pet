require 'active_support/core_ext/hash/keys'
require_relative 'base'

# Common code for the interactive scripts
module TeachersPet
  module Actions
    class NonInteractive < Base
      attr_reader :options

      def initialize(opts)
        @options = opts.symbolize_keys
      end

      ## TODO remove after fully off of Highline ##
      def ask(*args)
        raise "Shouldn't be ask()ing: #{args}"
      end

      def confirm(*args)
        raise "Shouldn't be confirm()ing: #{args}"
      end
      #############################################

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
