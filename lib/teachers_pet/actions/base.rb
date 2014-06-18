require 'active_support/core_ext/hash/keys'
require 'octokit'
require_relative File.join('..', 'configuration')

module TeachersPet
  module Actions
    class Base
      attr_reader :client, :options

      def initialize(opts={})
        @options = opts.symbolize_keys
      end

      def octokit_config
        opts = {
          api_endpoint: self.options[:api],
          web_endpoint: self.options[:web],
          login: self.options[:username],
          # Organizations can get big, pull in all pages
          auto_paginate: true
        }

        if self.options[:token]
          opts[:access_token] = self.options[:token]
        elsif self.options[:password]
          opts[:password] = self.options[:password]
        else
          raise Thor::RequiredArgumentMissingError.new("No value provided for option --password or --token")
        end

        opts
      end

      def init_client
        puts "=" * 50
        puts "Authenticating to GitHub..."
        octokit = Octokit::Client.new(self.octokit_config)
        @client = TeachersPet::ClientDecorator.new(octokit)
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
        student_file = self.options[:students]
        puts "Loading students:"
        read_file(student_file)
      end
    end
  end
end
