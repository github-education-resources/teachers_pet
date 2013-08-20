
class GithubCommon

  def initialize
  end

  def config_githib
    return unless @username.nil?
    @api_endpoint = ask('What is the API endpoint?') { |q| q.default = 'https://github.uc.edu/api/v3' }
    @web_endpoint = ask("What is the Web endpoint?") { |q| q.default = 'https://github.uc.edu/' }

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
    config_githib()
    puts "=" * 50
    puts "Authenticating to github..."
    Octokit.configure do |c|
      c.api_endpoint = @api_endpoint
      c.web_endpoint = @web_endpoint
    end
 
    if @authmethod == 'password'
      @client = Octokit::Client.new(:login => @username, :password => @password) 
    end
    if @authmethod == 'oauth'
      @client = Octokit::Client.new(:login => @username, :oauth_token => @oauthtoken) 
    end
  end

  def read_organization(organization)
    abort("Githib client not initialized") if @client.nil?
    @client.organization(organization)
  end

  protected
  def get_existing_repos_by_names(organization)
    repos = Hash.new
    @client.organization_repositories(organization).each do |repo|
      repos[repo[:name]] = repo
    end
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
