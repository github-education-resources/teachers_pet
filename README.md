scripts
=======

Scripts for working with github for academic purposes.

Author - Mike Helmick, University of Cincinnati
local github name: @helmicmt

Instructions
============

 * Create an organization (you will be an owner by default). The organization should reflect the name of your course.
 * Add the github username of all students to the 'students' file (one per line)
 * Add the github username of all instructors to the 'instructors' file (one per line)
 * Run ./create_teams.rb
 * For each assignment
 ** Run ./create_repos.rb to create a repository for each student

Pushing starter files
---------------------

TODO(@helmicmt): Write instructions and script for pushing starter files

Pulling repositories for grading
--------------------------------

TODO(@helmicmt): Write instructions and script for pulling all student repositories for grading

Philosophy
==========

These scripts are initially being written to support individual assignments. Team assignment support will be added in the future.

Each class is an 'organization' on github. This allows the instructors (github organization Owners) to create, push, pull, and administer all repositories. This achieves two goals:

 * Instructors can push code starter code to all students
 * Instructors can easily browse/pull student code at any time during the assignment to assist in questions, check on progress

Each student is given a team in the organization. The team name is the same as the student's github username. The course instructors are also added as team members for each team (see the goals above).

