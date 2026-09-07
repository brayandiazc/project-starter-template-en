# Repository labels

Labels categorize issues and pull requests. This file is the source of truth:
[`scripts/setup-labels.sh`](scripts/setup-labels.sh) **parses these tables** and creates
them on GitHub — there is no other copy to maintain.

There is no path-based auto-labeling: in a one-person repository, a label you have to
apply by hand and nobody queries is noise. The ones here are either applied by an
automation, or they change CI behavior, or they are useful to search by.

## Applied automatically

| Label          | Color     | Who applies it                        |
| -------------- | --------- | ------------------------------------- |
| `dependencies` | `#0366D6` | Dependabot (`dependabot.yml`)         |
| `ci-cd`        | `#F9D0C4` | Dependabot, on GitHub Actions updates |

## Type

| Label           | Color     | When                           |
| --------------- | --------- | ------------------------------ |
| `bug`           | `#D73A4A` | Something is not working right |
| `enhancement`   | `#A2EEEF` | New feature or improvement     |
| `documentation` | `#0075CA` | Documentation-only changes     |
| `question`      | `#D876E3` | Request for information        |

## Status

| Label             | Color     | When                       |
| ----------------- | --------- | -------------------------- |
| `breaking change` | `#B60205` | Breaks compatibility       |
| `blocked`         | `#B60205` | Blocked by a dependency    |
| `duplicate`       | `#CFD3D7` | Already exists             |
| `wontfix`         | `#FFFFFF` | This will not be worked on |

## CI exceptions

| Label          | Color     | Effect                                                                           |
| -------------- | --------- | -------------------------------------------------------------------------------- |
| `no-changelog` | `#C5DEF5` | The `changelog` job in `quality.yml` lets the PR through with no CHANGELOG entry |

> It is the **only** label that changes the CI result. Use it with a reason written in
> the PR: the rule is that every change gets documented.

## Creating the labels

```bash
bash .github/scripts/setup-labels.sh
```

It requires an authenticated [`gh`](https://cli.github.com). It is idempotent: it
creates the missing ones and updates the color and description of the existing ones.

## Adding a new one

1. Add it to the matching table in this file (name and color between backticks; the
   third column acts as the description) and run the script again.
2. If no automation applies it and it does not affect CI, ask yourself first whether you
   are actually going to use it.
