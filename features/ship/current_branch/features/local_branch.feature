Feature: ship a local feature branch

  Background:
    Given the current branch is a local feature branch "feature"
    And the commits
      | BRANCH  | LOCATION | MESSAGE        |
      | feature | local    | feature commit |
    When I run "git-town ship -m 'feature done'"

  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                         |
      | feature | git fetch --prune --tags        |
      |         | git checkout main               |
      | main    | git merge --squash --ff feature |
      |         | git commit -m "feature done"    |
      |         | git push                        |
      |         | git branch -D feature           |
    And the current branch is now "main"
    And the branches are now
      | REPOSITORY    | BRANCHES |
      | local, origin | main     |
    And these commits exist now
      | BRANCH | LOCATION      | MESSAGE      |
      | main   | local, origin | feature done |
    And no lineage exists now

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH | COMMAND                                       |
      | main   | git revert {{ sha 'feature done' }}           |
      |        | git push                                      |
      |        | git branch feature {{ sha 'feature commit' }} |
      |        | git checkout feature                          |
    And the current branch is now "feature"
    And these commits exist now
      | BRANCH  | LOCATION      | MESSAGE               |
      | main    | local, origin | feature done          |
      |         |               | Revert "feature done" |
      | feature | local         | feature commit        |
    And the initial branches and lineage exist
