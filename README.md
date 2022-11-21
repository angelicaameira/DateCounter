# DateCounter

Counts the time difference between the current date and user-defined events.

## Project target

This project uses Xcode 14 and SwiftUI life cycle and targets all Apple platforms: macOS, iOS, iPadOS, watchOS and tvOS.

## Default branch nomenclature

`reason` `/` `issueID`

### Reasons

- `feature`: development of new user-facing features
- `bug`: fixing bugs
- `technical`: improvement of non-user-facing code such as improving architecture or fixing technical debt
- `docs`: for tasks related to documentation only

### Issue IDs

- GitHub-generated issue ID. For example, the ID for the task shown below is #2
<img width="405" alt="image" src="https://user-images.githubusercontent.com/816290/119736502-2c9dc700-be54-11eb-81ac-7859899d8f59.png">

Examples:

- `feature/2`
- `bug/9`
- `technical/12`
- `docs/25`

### Git flow

- `main` - production branch
- `development` - development branch

Branches must generally be created from the `development` branch, and when its bugs and features are released into production, merged into `main`.

Committing directly into `main` or `development` is not allowed. Pull requests must pass code review.

While opening the pull request, the comment must note which issue is being worked on the PR.

Examples:
- For features: `closes #17`
- For bugs: `fixes #14`
