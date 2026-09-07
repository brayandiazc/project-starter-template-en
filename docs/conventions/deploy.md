# Deployment conventions

> [PROJECT_NAME]'s production operations. The source of truth for how the system is
> deployed, rolled back and operated.
> **Last updated**: [DATE]

> The concrete stack —engine, library, tools— is decided by the project and recorded by
> [`../architecture/stack.md`](../architecture/stack.md), with the why in
> [`../decisions/`](../decisions/README.md). Only the **rules** go here, which do not
> change when the tool changes.

## Environments

| Environment | URL              | Branch    | Deploy    |
| ----------- | ---------------- | --------- | --------- |
| Development | [DEV_URL]        | `develop` | Automatic |
| Production  | [PRODUCTION_URL] | `main`    | Manual    |

## Rules

- Production is only deployed from `main`, and every merge to `main` publishes a version.
- **Every deploy is reproducible and reversible.** With the container as the contract,
  going back is redeploying the previous image, not reverting code by hand.
- There is no `staging`: `develop` is the integration environment. A third environment
  nobody really uses only adds one more place for configuration to drift.
- Environment variables and secrets are managed per [`secrets.md`](secrets.md).
- Verify the health checks after every deploy.

## Deploy procedure

```bash
# 1. Build
[BUILD_COMMAND]

# 2. Deploy to the environment
[DEPLOY_COMMAND]

# 3. Verify
curl [HEALTHCHECK_URL]
```

## Rollback

```bash
[ROLLBACK_COMMAND]
```

## Backups: there are TWO, and they cover different failures

Confusing them means discovering mid-emergency that you only had half.

| Failure                                                                 | What saves you   | What does NOT                                             |
| ----------------------------------------------------------------------- | ---------------- | --------------------------------------------------------- |
| You deleted a table, a migration went wrong, corrupted data             | **The dump**     | The snapshot: it restores everything's old data           |
| You broke the machine: a failed OS upgrade, a full disk, broken runtime | **The snapshot** | The dump: it has the data, but there is nowhere to put it |

Plainly: **what the deploy tool does not cover and stays on you are OS updates and disk
space.** Those are exactly the two ways to break the machine, and the database dump covers
neither.

### The data dump

Daily, automatic, to a bucket separate from the application's. Script:
[`scripts/backup-db.sh`](../../scripts/backup-db.sh). 30-day retention.

### The machine snapshot

It is an image of the whole disk: OS, runtime, configuration, host keys. Restoring it
brings the server back to how it was, not the data to how it was.

**When it is taken** — not "every week", but **before whatever can break it**:

- Before every OS or kernel update.
- Before touching the container runtime, the firewall or the partitioning.
- And a periodic one in the background, in case the damage arrives without you causing it.

Write **your** provider's three commands here, exactly as they are run. This is not
decorative documentation: the day they are needed, nobody will be in a state to go looking
for them in a web panel.

```bash
# Create (name it with the date: in an emergency you pick by name, not by id)
[SNAPSHOT_CREATE_COMMAND]   # → "[PROJECT_NAME]-$(date +%F)" over [SERVER]

# List the existing ones
[SNAPSHOT_LIST_COMMAND]

# Restore ONTO the existing server — destructive, ask for confirmation
[SNAPSHOT_RESTORE_COMMAND]   # → [SERVER] from [SNAPSHOT_ID]
```

**Retention: the last [N], and old ones are deleted by hand.** Snapshots are billed per GB
stored, so a forgotten one is a charge that grows in silence.

> **The restore is tested, not assumed.** Once a month, and both of them: bring the dump
> up in a local database and rebuild a throwaway server from the latest snapshot. **A
> backup that was never restored is not a backup, it is an assumption** — and you find out
> on the day it matters.

## Health checks and monitoring

- Health endpoint: `[HEALTHCHECK_PATH]`.
- Error monitoring: [TOOL].
- Alerts: [Where and on what it notifies].

## If the product is a mobile app

**Everything above assumes a deploy is reverted with a command. On mobile it is not.**
A version installed on somebody's phone cannot be recovered: you can stop distributing it,
not remove it. And a portion of your users stays on old versions permanently.

That does not change a section: it changes the premise. Replace the ones above with these.

| Concept          | Server           | Mobile                                                                                                                                              |
| ---------------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Environments     | dev / production | Development · **TestFlight** and Play's internal track · production                                                                                 |
| Procedure        | one command      | build → upload → **store review** (hours or days) → publication                                                                                     |
| Rollback         | one command      | **It does not exist for the binary.** OTA updates revert the JavaScript; everything else is publishing a new version and waiting for another review |
| Health check     | an endpoint      | Crash rate per version and version adoption (error monitor and the stores' consoles)                                                                |
| The irreversible | —                | **There will be users on old versions forever.** That is why the API only adds fields, never deletes or renames                                     |

The rollback row is the one to read twice: **it is the reason the API rule is
non-negotiable.** It is not rigidity, it is that there is no way back.

### Before the first submission

Three requirements that are not technical, get discovered late and **block publication**:

- **Login**: if you offer a third-party social login for the main account, the App Store
  requires an equivalent alternative that limits data to name and email, allows hiding the
  email and does not track for advertising (guideline 4.8). Sign in with Apple meets it.
- **A privacy policy** reachable from the store listing and from inside the app.
- **Account deletion from inside the app**, not only by email or from the web.
