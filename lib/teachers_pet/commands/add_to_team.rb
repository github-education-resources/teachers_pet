module TeachersPet
  class Cli
    option :organization, required: true
    # TODO make team name configurable
    option :members, required: true, banner: 'PATH', desc: "The path to the file containing the list of members to add. The filename will be used as the name of the team, e.g. `path/to/instructors.csv` will use the 'instructors' team."
    common_options

    desc 'add_to_team', "Adds each user in the list to the team specified by the filename. Creates the team on the specified organization if it doesn't already exist."
    def add_to_team
      TeachersPet::Actions::AddToTeam.new(options).run
    end
  end
end
