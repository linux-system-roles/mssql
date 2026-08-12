# Bug report: `mssql-server-selinux` policy module is incomplete on RHEL 10 — `/var/opt/mssql/{data,.system}` resolve to `usr_t` and `mssql_server_t` has no write rules for its own directories

## Summary

On Red Hat Enterprise Linux 10, running SQL Server 2025 as a **confined
SELinux application** fails because the `mssql-server-selinux` policy module is
incomplete:

1. The loaded module provides **no file-context entries** for
   `/var/opt/mssql/data` or `/var/opt/mssql/.system`, so those runtime
   directories resolve to the default `usr_t`. `restorecon` can therefore never
   label them correctly — there is nothing to restore them *to*.
2. The `mssql_server_t` domain has **no allow rules to write** the directory
   types under its own tree (`mssql_opt_t`, and no `mssql_var_t` write rule
   either). So even the directories that *are* labeled correctly cannot be
   written by the confined server domain.

The result is that `mssql-conf setup` is denied access under enforcing mode.
This is a **policy-completeness defect in the shipped module**, not merely a
`%posttrans` relabel-ordering problem as an earlier draft of this report
assumed.

## Environment

| Item | Value |
| --- | --- |
| OS | Red Hat Enterprise Linux 10 |
| SQL Server | 2025 (17.x) |
| `mssql-server-selinux` | `17.0.4065.4-1` |
| `selinux-policy` | `42.1.18-4.el10_2.noarch` |
| SELinux | `enforcing`, policy type `targeted` |
| Loaded mssql module | `200 mssql pp` (priority 200, from `mssql-server-selinux`) |
| Server repo | `https://packages.microsoft.com/rhel/10/mssql-server-2025/` |

Note: `mssql-server-selinux` declares no minimum `selinux-policy` version, and
the installed policy is current — this is not a policy-version mismatch.

## Evidence

All commands below query the **currently loaded** policy, which is
authoritative for how the running system labels files and what the confined
domains are allowed to do.

### 1. The loaded module has no fcontext for `data` / `.system`

`matchpathcon` resolves against the loaded file-context database:

```console
# matchpathcon /opt/mssql /var/opt/mssql /var/opt/mssql/.system /var/opt/mssql/data
/opt/mssql              system_u:object_r:mssql_opt_t:s0
/var/opt/mssql          system_u:object_r:mssql_opt_t:s0
/var/opt/mssql/.system  system_u:object_r:usr_t:s0
/var/opt/mssql/data     system_u:object_r:usr_t:s0
```

Two facts follow directly:

- `/var/opt/mssql` maps to **`mssql_opt_t`** (not a dedicated `mssql_var_t`).
- `/var/opt/mssql/.system` and `/var/opt/mssql/data` have **no matching
  fcontext entry at all** and fall through to the default `usr_t`.

Because these paths have no entry in the loaded policy, `restorecon -R
/var/opt/mssql` cannot fix them — it has no target type to apply.

### 2. On-disk labels confirm the resolution

```console
# ls -ldZ /opt/mssql /opt/mssql/bin/mssql-conf /var/opt/mssql
drwxr-xr-x. 4 root  root  system_u:object_r:mssql_opt_t:s0        /opt/mssql
-rwxrwxr-x. 1 root  root  system_u:object_r:mssql_conf_exec_t:s0  /opt/mssql/bin/mssql-conf
drwxrwx---. 6 mssql mssql unconfined_u:object_r:mssql_opt_t:s0    /var/opt/mssql
```

`/opt/mssql`, `/opt/mssql/bin/mssql-conf`, and `/var/opt/mssql` themselves are
labeled as the loaded policy expects. The problem is not the top-level dirs —
it is the runtime-created children (`data`, `.system`, `log`, …) that inherit
`usr_t`.

### 3. `mssql_server_t` has no write rules for its own directory types

```console
# sesearch -A -s mssql_server_t -t mssql_var_t -c dir -p write
(no output)
# sesearch -A -s mssql_server_t -t mssql_opt_t -c dir -p write
(no output)
```

There is no allow rule permitting the confined server domain to write
directories of type `mssql_opt_t` (the type `/var/opt/mssql` actually carries)
or `mssql_var_t`. So even a perfectly relabeled tree would still be denied:
the module ships file types without the corresponding domain-to-type access
rules.

### 4. Symptom

`mssql-conf setup` (or first `sqlservr` start) is denied under enforcing mode
when it tries to create its working directories:

```
/opt/mssql/bin/sqlservr: Error: Directory [/var/opt/mssql/.system/system] could not
be created. [Status: 0xC0000022 Access denied errno = 0xD(13) Permission denied]
```

The corresponding AVC has `scontext=…:mssql_server_t` and
`tcontext=…:usr_t` for the `.system` directory — consistent with evidence #1
(the child dir is `usr_t`) and #3 (no write rule even if it weren't).

## Root cause

The `mssql-server-selinux` module shipped for RHEL 10 is incomplete in two
independent ways:

1. **Missing file contexts** for the directories SQL Server creates at runtime
   under `/var/opt/mssql` (`data`, `.system`, `log`, etc.). With no fcontext
   and no `type_transition`/`filetrans` rules, those directories are created as
   `usr_t` and no relabel step can correct them.
2. **Missing access-vector rules** for `mssql_server_t` to manage the directory
   types under its tree (`mssql_opt_t` / `mssql_var_t` dir write, add_name,
   create, etc.).

Either defect alone is sufficient to break confined operation; both are
present. This is why `restorecon`-based workarounds do not fully resolve the
failure on RHEL 10.

### Relationship to the earlier "posttrans relabel" theory

An earlier draft attributed the failure to the package's `%posttrans` relabel
being skipped when `/var/opt/mssql` does not yet exist, and cited an extracted
`.fc` containing `/var/opt/mssql(/.*)? → mssql_var_t` and
`/var/opt/mssql/data(/.*)? → mssql_db_t`. The **loaded** policy on RHEL 10 does
**not** contain those entries (see evidence #1), so that extraction did not
reflect what is actually installed. The relabel-ordering issue may compound the
problem, but it is not the primary cause: even with the top-level dirs labeled
correctly (as they are here), setup still fails because the child directories
have no defined type and the server domain has no write rules.

## Reproduction

On a RHEL 10 host with SELinux enforcing:

```sh
dnf install -y mssql-server mssql-server-selinux

# Loaded policy has no fcontext for the runtime dirs:
matchpathcon /var/opt/mssql/data /var/opt/mssql/.system   # => usr_t (both)

# Server domain cannot write its own dir types:
sesearch -A -s mssql_server_t -t mssql_opt_t -c dir -p write   # => (empty)

MSSQL_SA_PASSWORD='p@55w0rD' ACCEPT_EULA=Y MSSQL_PID=Evaluation \
  /opt/mssql/bin/mssql-conf --noprompt setup      # => Permission denied
```

## Workaround

A pure `restorecon` workaround is **not sufficient** on RHEL 10, because the
loaded policy defines no target types for `/var/opt/mssql/{data,.system}` and
no write rules for `mssql_server_t`. Practical options:

- **Set the `mssql` domain permissive** so the confined labels don't block
  operation while the packaged policy is incomplete:
  ```sh
  semanage permissive -a mssql_server_t
  ```
- Or **add a local policy module** that supplies the missing fcontexts and
  allow rules (generate from denials with `audit2allow -M mssql-local` after a
  permissive run, then review before loading).

Neither is a proper fix — both belong in the shipped `mssql-server-selinux`
package.

## Suggested package fix

In `mssql-server-selinux` for RHEL 10:

1. Ship file-context entries (and/or `filetrans` rules) so runtime-created
   directories under `/var/opt/mssql` (`data`, `.system`, `log`, …) receive the
   intended `mssql_*` types automatically, rather than inheriting `usr_t`.
2. Ship the corresponding allow rules so `mssql_server_t` can create and write
   directories/files of those types.
3. Do not rely on `%posttrans` `fixfiles`/`restorecon` alone for correct
   labeling — with `type_transition` rules in place, correct labels no longer
   depend on a post-hoc relabel.

## Impact

Any automated/first-boot deployment that installs the packages and runs
`mssql-conf setup` under SELinux enforcing (the default on RHEL 9+) fails out
of the box on RHEL 10 — including the `linux-system-roles.mssql` Ansible role.
Until the package is fixed, the role must apply a workaround (e.g. mark
`mssql_server_t` permissive) on RHEL 10.
