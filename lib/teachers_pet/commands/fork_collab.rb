module TeachersPet
  class Cli
    option :repository, required: true, banner: 'OWNER/REPO'
    option :dry_run, type: :boolean
    common_options

    desc "fork_collab", "Give collaborator access to everyone who has forked a particular repository."
    def fork_collab
      TeachersPet::Actions::ForkCollab.new(options).run
    end
  end
end
