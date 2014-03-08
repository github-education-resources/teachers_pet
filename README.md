# teachers_pet

Command line tools that are useful for teaching

## Usage

`gem install teachers_pet`

`forkcollab` - give collab access to everyone who has forked your repository

## Installation

 * Clone this git repository
 * Install the following ruby gems
     * octokit
     * highline

## Basic Setup

 * Create an organization (you will be an owner by default). The organization should reflect the name of your course.
 * Add the github username of all students to the 'students' file (one per line)
 ** If you are doing individual assignments, use a single username per line
 ** If you are doing team assignments, one team per line in the format "teamName username username username"
 * Add the github username of all instructors to the 'instructors' file (one per line)
 * Run create_teams.rb

## Passwords / OAuth

The scripts will ask for your github password in order to run. If you have two factor authentication enabled, you might want to create a new OAuth personal token to run these scripts. You can do this here: https://github.com/settings/tokens/new (or settings screen on your enterprise installation).

If you put this OAuth token in an environment variable called 'ghe_oauth', these scripts will automatically pick up that value.

The OAuth token will need the following permissions

 * repo
 * public_repo
 * write:org
 * repo:status
 * read:org
 * user
 * admin:org

## Creating Assignments

For each assignment, run create\_repos.rb to create a repository for each student. The repositories are technically created per team, but if you use create\_teams.rb first, then there will be one team per student.

### Pushing starter files

This is the workflow that we use. Create a private repository on github. Clone it to your machine and place in all the necessary starter files (.gitignore and build files, like Makefile are highly recommended). Commit and push this repository to the origin.

While in the directory for the starter file repository, run the "push\_repos.rb" script.

This works by creating a git remote for each repository and thing doing a push to that repository.

### Pulling repositories for grading

When grading, use the clone\_repos.rb script to clone all the repositories in the organization that match the username-repository naming scheme that is generated when create\_repos is run.

## Philosophy

Each class is an 'organization' on github. This allows the instructors (github organization Owners) to create, push, pull, and administer all repositories. This achieves two goals:

 * Instructors can push code starter code to all students
 * Instructors can easily browse/pull student code at any time during the assignment to assist in questions, check on progress

Each student is given a team in the organization. The team name is the same as the student's github username. The course instructors are also added as team members for each team (see the goals above).
