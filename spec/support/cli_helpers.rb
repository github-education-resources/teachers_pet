module CliHelpers
  def teachers_pet(action, opts={})
    script = TeachersPet::Cli.new
    script.invoke(action, [], opts)
  end

  def expect_to_be_run_with(cls, opts)
    expect(cls).to receive(:new).with(opts).once.and_call_original
    expect_any_instance_of(cls).to receive(:run).once
  end
end
