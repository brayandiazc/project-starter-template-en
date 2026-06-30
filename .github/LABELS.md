# GitHub Label Configuration

Labels categorize Issues and Pull Requests. The [`labeler.yml`](labeler.yml) file
automatically assigns labels to PRs based on the files modified.

## Automatic Labels (assigned by the labeler)

These must exist in the repository for the labeler to work.

| Label           | Color     | Description                         |
| --------------- | --------- | ----------------------------------- |
| `documentation` | `#0075CA` | Documentation changes               |
| `frontend`      | `#0052CC` | UI / client changes                 |
| `styles`        | `#BFD4F2` | CSS / styling changes               |
| `backend`       | `#006B75` | Server / API / logic changes        |
| `database`      | `#5319E7` | Migrations, schema, or seeds        |
| `testing`       | `#FBCA04` | Test changes                        |
| `dependencies`  | `#0366D6` | Dependency updates                  |
| `config`        | `#D4C5F9` | Configuration changes               |
| `ci-cd`         | `#F9D0C4` | CI/CD, workflow, and Docker changes |
| `github`        | `#333333` | GitHub template and config changes  |

## Manual Labels

| Label              | Color     | Description                       |
| ------------------ | --------- | --------------------------------- |
| `bug`              | `#D73A4A` | Something isn't working correctly |
| `enhancement`      | `#A2EEEF` | New feature or improvement        |
| `breaking change`  | `#B60205` | Changes that break compatibility  |
| `needs review`     | `#FBCA04` | Requires review                   |
| `work in progress` | `#FEF2C0` | Work in progress                  |
| `ready for merge`  | `#0E8A16` | Approved and ready to merge       |
| `blocked`          | `#B60205` | Blocked by dependencies           |
| `help wanted`      | `#008672` | External help needed              |
| `good first issue` | `#7057FF` | Good for new contributors         |
| `duplicate`        | `#CFD3D7` | Duplicate issue or PR             |
| `invalid`          | `#E4E669` | Not valid or not applicable       |
| `wontfix`          | `#FFFFFF` | This will not be worked on        |
| `question`         | `#D876E3` | Request for information           |

## Creating Labels

### Option 1: Automatic script (recommended)

```bash
gh auth login
bash .github/scripts/setup-labels.sh
```

### Option 2: Manually on GitHub

1. Go to your repository → **Issues** → **Labels**.
2. Click **New label**.
3. Create each label with the name, color, and description from the tables above.

## Customize

To add a new automatic label:

1. Create the label on GitHub (manually or with the script).
2. Add the rule in [`labeler.yml`](labeler.yml).
3. Document it in this file and in `setup-labels.sh`.
