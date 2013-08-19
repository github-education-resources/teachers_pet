
class GithubCommon

  def initialize
  end

  def config_githib
    return unless @username.nil?
    @api_endpoint = ask('What is the API endpoint?') { |q| q.default = 'https://github.uc.edu/api/v3' }
    @web_endpoint = ask("What is the Web endpoint?") { |q| q.default = 'https://github.uc.edu/' }

    @username = ask('What is your username? (You must be an owner for the organization)?') { |q| q.default = ENV['USER'] }
    @password = ask('What is your password?') { |q| q.echo = false }
  end

  def init_client
    config_githib()
    puts "=" * 50
    puts "Authenticating to github..."
    Octokit.configure do |c|
      c.api_endpoint = @api_endpoint
      c.web_endpoint = @web_endpoint
    end
    @client = Octokit::Client.new(:login => @username, :password => @password)
  end

  def read_organization(organization)
    abort("Githib client not initialized") if @client.nil?
    @client.organization(organization)
  end

  protected
  def get_team_members(team_id)
    team_members = Hash.new
    @client.team_members(team_id).each do |member|
      team_members[member[:login]] = member
    end
    return team_members
  end

  def read_file(filename, type)
    set = Hash.new
    puts "Loading #{type}:"
    File.open(filename).each_line do |user|
      # Trim whitespace, otherwise issues occur
      user.strip!
      abort("No users can be named 'owners' (in any case)") if 'owners'.eql?(user.downcase)
      if set[user].nil?
        puts " -> #{user}"
        set[user] = true
      end
    end
    return set
  end

  def confirm(message)
    # confirm
    confirmed = false
    choose do |menu|
      menu.prompt = message

      menu.choice :yes do confirmed = true end
      menu.choice :no do confirmed = false end
    end
    abort("Creation cancled by user") unless confirmed
    return true
  end
end