# teachers_pet [![Build Status](https://travis-ci.org/education/teachers_pet.svg?branch=master)](https://travis-ci.org/education/teachers_pet)

**WARNING: This documentation may contain unreleased changes. See [rubydoc.info/gems/teachers_pet](http://rubydoc.info/gems/teachers_pet) for the version of this README correspoding to the latest release.**

Command line tools to help teachers use GitHub in their classrooms.

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

## Basic Setup

* Create an organization (you will be an owner by default). The organization should reflect the name of your course.
* Create a `students` file (you will be prompted for the path later)
    * Individual assignments: one username per line
    * Group assignments: one team per line in the format `teamName username username username`
* Add the GitHub username of all instructors to an 'instructors' file (one per line)
* Run `create_teams`

## Authentication

The scripts will ask for your GitHub password in order to run. If you have [two factor authentication](https://help.github.com/articles/about-two-factor-authentication) (2FA) enabled, [create a personal access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use) (replace `github.com` with your host for GitHub Enterprise):

https://github.com/settings/tokens/new?description=teachers_pet&scopes=repo%2Cpublic_repo%2Cwrite%3Aorg%2Crepo%3Astatus%2Cread%3Aorg%2Cuser%2Cadmin%3Aorg

Then, add the following line to your `.bash_profile`:

```bash
export TEACHERS_PET_GITHUB_TOKEN="YOUR_TOKEN_HERE"
```

## Actions

### Creating assignments

For each assignment, run `create_repos` to create a repository for each student. The repositories are technically created per team, but if you use `create_teams` first, then there will be one team per student.

### Collaborator access

Give collaborator access to everyone who has forked your repository.

```bash
teachers_pet fork_collab --repository=USER/REPO
```

Learn more with

```bash
teachers_pet help fork_collab
```

### Pushing starter files

This is the workflow that we use. Create a private repository on GitHub. Clone it to your machine and place in all the necessary starter files (.gitignore and build files, like Makefile are highly recommended). Commit and push this repository to the origin.

While in the directory for the starter file repository, run the `push_repos` script.

This works by creating a git remote for each repository and thing doing a push to that repository.

### Opening issues

After running `create_repos`, instructors can open issues in repos with `open_issue`.  This action requires an `issue.md` file containing the body of the issue.  The issue title and optional tags are added at runtime.

One issue will be opened in every repo defined by the `students` file and repository name given by the user.

Open issues in student repos as a way to list requirements of the assignment, goals, or instructions for patching.

### Pulling repositories for grading

When grading, use the `clone_repos` script to clone all the repositories in the organization that match the username-repository naming scheme that is generated when `create_repos` is run.

## Related projects

* https://education.github.com/guide
* https://github.com/hogbait/6170_repo_management
* https://github.com/mikehelmick/edugit-scripts
* https://github.com/UCSB-CS-Using-GitHub-In-Courses/github-acad-scripts
