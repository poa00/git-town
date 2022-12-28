Feature: "rebase" sync strategy

  Background:
    Given setting "sync-strategy" is "rebase"
    And the current branch is a feature branch "feature"
    And the commits
      | BRANCH  | LOCATION      | MESSAGE        |
      | feature | local, origin | feature commit |
    When I run "git-town ship" and enter "feature done" for the commit message

  Scenario: result
    Then it runs the commands
      | BRANCH  | COMMAND                    |
      | feature | git fetch --prune --tags   |
      |         | git checkout main          |
      | main    | git rebase origin/main     |
      |         | git checkout feature       |
      | feature | git rebase origin/feature  |
      |         | git rebase main            |
      |         | git checkout main          |
      | main    | git merge --squash feature |
      |         | git commit                 |
      |         | git push                   |
      |         | git push origin :feature   |
      |         | git branch -D feature      |
    And the current branch is now "main"
    And the branches are now
      | REPOSITORY    | BRANCHES |
      | local, origin | main     |
    And now these commits exist
      | BRANCH | LOCATION      | MESSAGE      |
      | main   | local, origin | feature done |
    And no branch hierarchy exists now

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH  | COMMAND                                       |
      | main    | git branch feature {{ sha 'feature commit' }} |
      |         | git push -u origin feature                    |
      |         | git revert {{ sha 'feature done' }}           |
      |         | git push                                      |
      |         | git checkout feature                          |
      | feature | git checkout main                             |
      | main    | git checkout feature                          |
    And the current branch is now "feature"
    And now these commits exist
      | BRANCH  | LOCATION      | MESSAGE               |
      | main    | local, origin | feature done          |
      |         |               | Revert "feature done" |
      | feature | local, origin | feature commit        |
    And the initial branches and hierarchy exist