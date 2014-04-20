# teachers_pet [![Build Status](https://travis-ci.org/education/teachers-pet.svg?branch=master)](https://travis-ci.org/education/teachers-pet)

Command line tools to help teachers use GitHub in their classrooms.

## Installation

[Install Ruby 1.9.3+](https://www.ruby-lang.org/en/installation/), then run

```bash
gem install teachers_pet
```

## Basic Setup

* Create an organization (you will be an owner by default). The organization should reflect the name of your course.
* Add the GitHub username of all students to the 'students' file (one per line)
    * If you are doing individual assignments, use a single username per line
    * If you are doing team assignments, one team per line in the format "teamName username username username"
* Add the GitHub username of all instructors to the 'instructors' file (one per line)
* Run `create_teams`

## Passwords / OAuth

The scripts will ask for your GitHub password in order to run. If you have two factor authentication enabled, you might want to create a new OAuth personal token to run these scripts. You can do this here: https://github.com/settings/tokens/new (or settings screen on your enterprise installation).

If you put this OAuth token in an environment variable called 'ghe_oauth', these scripts will automatically pick up that value.

The OAuth token will need the following permissions

* repo
* public_repo
* write:org
* repo:status
* read:org
* user
* admin:org

## Actions

### Creating assignments

For each assignment, run `create_repos` to create a repository for each student. The repositories are technically created per team, but if you use `create_teams` first, then there will be one team per student.

### Collaborator access

Give collaborator access to everyone who has forked your repository.

```bash
fork_collab
```

### Pushing starter files

This is the workflow that we use. Create a private repository on GitHub. Clone it to your machine and place in all the necessary starter files (.gitignore and build files, like Makefile are highly recommended). Commit and push this repository to the origin.

While in the directory for the starter file repository, run the `push_repos` script.

This works by creating a git remote for each repository and thing doing a push to that repository.

### Pulling repositories for grading

When grading, use the `clone_repos` script to clone all the repositories in the organization that match the username-repository naming scheme that is generated when `create_repos` is run.

## Philosophy

Each class is an 'organization' on GitHub. This allows the instructors (GitHub organization Owners) to create, push, pull, and administer all repositories. This achieves two goals:

* Instructors can push code starter code to all students
* Instructors can easily browse/pull student code at any time during the assignment to assist in questions, check on progress

Each student is given a team in the organization. The team name is the same as the student's GitHub username. The course instructors are also added as team members for each team (see the goals above).

## Related projects

* https://education.github.com/guide
* https://github.com/hogbait/6170_repo_management
* https://github.com/mikehelmick/edugit-scripts
* https://github.com/UCSB-CS-Using-GitHub-In-Courses/github-acad-scripts
