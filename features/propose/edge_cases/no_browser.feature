@skipWindows
Feature: print the URL when no browser installed

  Background:
    Given a Git repo with origin
    And the branch
      | NAME    | TYPE    | PARENT | LOCATIONS     |
      | feature | feature | main   | local, origin |
    And the origin is "git@github.com:git-town/git-town"
    And no tool to open browsers is installed
    And the current branch is "feature"
    When I run "git-town propose"

  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                                 |
      | feature | git fetch --prune --tags                |
      |         | git checkout main                       |
      | main    | git rebase origin/main                  |
      |         | git checkout feature                    |
      | feature | git merge --no-edit --ff origin/feature |
      |         | git merge --no-edit --ff main           |
    And it prints:
      """
      Please open in a browser: https://github.com/git-town/git-town/compare/feature?expand=1
      """

  Scenario: undo
    When I run "git-town undo"
    Then it runs no commands
