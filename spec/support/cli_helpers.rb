module CliHelpers
  def teachers_pet(action, opts={})
    script = TeachersPet::Cli.new
    script.invoke(action, [], opts)
  end
end
