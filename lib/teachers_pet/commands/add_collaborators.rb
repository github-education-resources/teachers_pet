module TeachersPet
  class Cli
    option :repository, required: true, banner: 'OWNER/REPO'
    option :members, required: true, banner: 'PATH', desc: "The path to the file containing the list of usernames to add."
    option :dry_run, type: :boolean, default: false
    common_options

    desc "add_collaborators", "Give collaborator access to each provided user."
    def add_collaborators
      TeachersPet::Actions::AddCollaborators.new(options).run
    end
  end
end
