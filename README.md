# teachers_pet [![Build Status](https://travis-ci.org/education/teachers_pet.svg?branch=master)](https://travis-ci.org/education/teachers_pet)

**WARNING: This documentation may contain unreleased changes. See [rubydoc.info/gems/teachers_pet](http://rubydoc.info/gems/teachers_pet) for the version of this README corresponding to the latest release.**

Command line tool to help teachers use GitHub in their classrooms.

## Philosophy

Each class is an 'organization' on GitHub. This allows the instructors (GitHub organization Owners) to create, push, pull, and administer all repositories. This achieves two goals:

* Instructors can push code starter code to all students
* Instructors can easily browse/pull student code at any time during the assignment to assist in questions, check on progress

Each student is given a team in the organization. The team name is the same as the student's GitHub username. The course instructors are also added as team members for each team (see the goals above).

## Installation

[Install Ruby 1.9.3+](https://www.ruby-lang.org/en/installation/), then run

```bash
gem install teachers_pet
```

If you've used this tool before, get the newest version using

```ruby
gem update teachers_pet
```

To use the latest-and-greatest code from this repository, see the instructions in [CONTRIBUTING.md](CONTRIBUTING.md).

## Typical workflow

...when using the [sandboxing](https://education.github.com/guide/sandboxing) method with [private repositories](https://education.github.com/guide/private_repos):

### Basic setup

1. Create an organization (you will be an owner by default). The organization should reflect the name of your course. See [the classroom guide](https://education.github.com/guide#2-create-an-organization-for-your-class) for more info.
1. Have each student/instructor create GitHub accounts.
1. Create a `students` file (you can use an alternate filename and specify with the `--students` option if you like)
    * Individual assignments: one username per line
    * Group assignments: one team per line in the format `teamName username username username`
1. Add the GitHub username of all instructors to an `instructors` file (one per line)
1. Run `create_teams`

### Assignments

```bash
teachers_pet create_repos ...
teachers_pet push_files ...
# Multiple times:
teachers_pet open_issue ...

# Then, after the assignment is due,
teachers_pet clone_repos ...
```

## Authentication

The scripts will ask for your GitHub password in order to run. If you have [two factor authentication](https://help.github.com/articles/about-two-factor-authentication) (2FA) enabled, [create a personal access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use) (replace `github.com` with your host for GitHub Enterprise):

https://github.com/settings/tokens/new?description=teachers_pet&scopes=repo%2Cpublic_repo%2Cwrite%3Aorg%2Crepo%3Astatus%2Cread%3Aorg%2Cuser%2Cadmin%3Aorg

Once created, specify the token using the `--token` option, or if you add the `TEACHERS_PET_GITHUB_TOKEN` environment variable to your `.bash_profile` (or equivalent – example below), it will be picked up by `teachers_pet`.

```bash
# replace YOUR_TOKEN_HERE below
echo "\n\nexport TEACHERS_PET_GITHUB_TOKEN=YOUR_TOKEN_HERE" >> ~/.bash_profile
source ~/.bash_profile
```

## Actions

**To learn the options for each action, run**

```bash
teachers_pet help
# or
teachers_pet help COMMAND
```

### Creating assignments

When using the [sandboxing](https://education.github.com/guide/sandboxing) setup, you will need to create the repositories for the students.  For each assignment, use the `create_repos` action to create a repository for each student.  The repositories are technically created per team, but if you use `create_teams` first, then there will be one team per student.

### Collaborator access

Give [collaborator access](https://help.github.com/articles/what-are-the-different-access-permissions#collaborator) to everyone who has forked your repository using `fork_collab`.  Mostly useful for GitHub demonstrations, where the students can quickly be added to a repository without having to worry about collecting usernames.

### Pushing starter files

When creating repositories for students, you will often want to include boilerplate files.  After running `create_repos`, create a canonical copy of the starter files (e.g. `.gitignore`, `Makefile`s, etc.) in a repository.  From the local clone of the repository, use the `push_files` action to place that code in the repositories for each student.  This works by creating a Git remote for each student repository, and doing a `git push` to each one.

### Opening issues

After running `create_repos`, instructors can open issues in student repos as a way to list requirements of the assignment, goals, or instructions for patching, using the `open_issue` command.

### Pulling repositories for grading

When grading, use the `clone_repos` command to clone all the repositories in the organization that match the username-repository naming scheme that is generated when `create_repos` is run.

## Related projects

* https://education.github.com/guide
* https://github.com/hogbait/6170_repo_management
* https://github.com/UCSB-CS-Using-GitHub-In-Courses/github-acad-scripts
