module CommonHelpers
  def stub_get_json(url, response)
    stub_request(:get, url).to_return(
      headers: {
        'Content-Type' => 'application/json'
      },
      body: response.to_json
    )
  end

  def fixtures_path
    File.join(File.dirname(__FILE__), '..', 'fixtures')
  end

  def students_list_fixture_path
    File.join(fixtures_path, 'students')
  end

  def instructors_list_fixture_path
    File.join(fixtures_path, 'instructors')
  end

  def empty_list_fixture_path
    File.join(fixtures_path, 'empty')
  end

  def issue_fixture_path
    File.join(fixtures_path, 'issue.md')
  end

  def student_usernames
    CSV.read(students_list_fixture_path).flatten
  end

  def instructor_usernames
    CSV.read(instructors_list_fixture_path).flatten
  end

  def student_teams
    student_usernames.each_with_index.map do |username, i|
      {
        url: "https://api.github.com/teams/#{i}",
        name: username,
        id: i
      }
    end
  end
end
