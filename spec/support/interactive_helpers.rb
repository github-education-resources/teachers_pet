module InteractiveHelpers
  extend ActiveSupport::Concern

  included do
    before do
      # fallback
      allow(action).to receive(:ask){|question| raise("can't ask \"#{question}\"") }
      allow(action).to receive(:choose){ raise("can't choose()") }

      allow(action).to receive(:confirm)
    end
  end

  def respond(question, response)
    allow(action).to receive(:ask).with(question).and_return(response)
  end

  def confirm(question, response)
    allow(action).to receive(:confirm).with(question, false).and_return(response)
  end

  def stub_github_config
    respond("What is the API endpoint?", TeachersPet::Configuration.apiEndpoint)
    respond("What is the Web endpoint?", TeachersPet::Configuration.webEndpoint)
    respond("What is your username? (You must be an owner for the organization)?", 'testteacher')
    allow(action).to receive(:get_auth_method) { 'password' }
    respond("What is your password?", 'abc123')
  end
end
