Changelog
=========

[1.3.0] - 2022-12-21
--------------------
### New Features

- Add support for SQL Server 2022 (#148)
  - Set mssql_version to null by default and require users to specify it
  - Set mssql_version if user didn't and if SQL Server package exists
  - Set mssql_version to none if it is not set and no current ver exists
  - Add workarounds for known issues in SQL Server 2022
  - Use delay=3 timeout=40 in wait_for module to avoid unreachable server

- Imrpove performance by intputting multiple SQL files with loop internaly (#116)
  - Make it possible to input multiple file with loop internally
  - Rename task file and vars for clarity
  - Make regex for files extension search more strict
  - Make mode consistent between template and copy tasks

- Add support for configuring asynchronous replicas (#121)
  - Add support for configuring asynchronous replicas
  - Add __mssql_ha_replica_types variables for code readability
  - Add test for error when primary is not defined

- Use the certificate role to create the cert and the key (#125)
  - Introduce a variable mssql_tls_certificates to set the certificate_requests.
  - Add the test case to test_tls_2019.yml
  - Apply basename to mssql_tls_certificates.name
    In case a full path of a relative path is set to mssql_tls_certificates.name,
    just get the basename part of the name and pass it to certificate_requests
    to create the private key and the cert in /etc/pki/tls where the setype is
    cert_t and the certificate role has the permission to create the files.

- Allow *_input_sql_files vars to take lists and strings (#124)

- Add support for read-scale always on clusters (#134)
  - Add support for read-scale always on clusters
  - Improve tmp file names and logging for sqlcmd_input_file
  - Add __mssql_single_node_test as a workaround for single-node tests
  
### Bug Fixes

- Fix creating a read-only cluster and setting db_names to empty list (#152)
  - Fix a bug when listener were created on mssql_ha_ag_cluster_type=none
  - Fix a bug when setting mssql_ha_db_names to empty list didn't work

- With sqlcmd, set password with env variable instead of -P for security (#153)

- Identify the current primary replica and configure ag on it (#113)
  Previously, the role configured AG on the server that has the
  `mssql_ha_replica_type: primary` variable set.
  However, in the case of fail over the primary replica moves to a
  different server.
  With this change, the role identifies the current primary server and
  configures AG on it.
  - Group input_sql_file.yml tasks to improve performance
  - Make test work in CI and when testing against multiple hosts manually

- Check if primary is available prior to configuring HA (#117)
  - Previously, in the case that the primary node failed before the role run tasks to configure for high availability, the role failed unexpectedly. Now, the role fails with an error message that primary node is not available.

- Add no_log true to tasks listing credentials on output (#119)
  For sqlcmd_input_sql_file add tasks to block to print the output of
  sqlcmd in case it fails. It is now required because the task itself has
  no_log true.

- Set __mssql_single_node_test to be false when not set (#143)
  Remove redundant empty line in weekly CI job

### Other Changes

- weekly-ci: do not create a new PR every time

- python version depends on platform; upgrade checkout, setup-python; support py311 [citest skip] (#142)
  - The python version used now requires a corresponding os version e.g. python 2.7 and
    python 3.6 are no longer supported on ubuntu-latest - must use 20.04.  Update
    the python matrix to include the os to use as well.
  - Use checkout@v3 and setup-python@v4
  - python 3.11 stable is now supported by setup-python
  - Add `push` action for status reporting on role main page if missing
  - Use `docker` for ansible-test if not already doing that

- Set __mssql_single_node_test to be false when not set (#143)

- Cleanup tests for vault (#151)
  - delete a repeating task added by mistake
  - use the string name instead of the number for noqa
  - In clean up playbook also remove repo files
  - Add tests_idempotency_* to no-vault-variables.txt
  - Define different test passwords consistently
  - Incorporate tests_powershell to tests_idempotency
  - Add tests_input_sql_file_2017
  - Remove redundant no_log in tests/tasks/
  - Add missing input_sql_file_2017 to no-vault-variables

- Move all ha-related tasks under a single block to clear code (#118)

- Add support for CI testing with ansible_vault
  Excluding tests that re-define variables because CI provides encrypted
  variables with env var and they take the highest precedence

- Fix Reload service daemon task taking 30 min (#120)

- Remove support for Fedora 36 (#123)
  mssql-server package does not support Fedora at all but it works on
  Fedora <36. Once Microsoft adds mssql-server package for RHEL 9 it
  should work on Fedora 36 too.

- Clean up role code (#126)
  - Replace `str` with `string` in README for consistency
  - Remove flush_handlers from tests because role does it each invocation

- add github action for weekly ci (#127)

- weekly-ci: do not create a new PR every time

- python version depends on platform; upgrade checkout, setup-python; support py311 [citest skip] (#142)
  The python version used now requires a corresponding os version e.g. python 2.7 and
  python 3.6 are no longer supported on ubuntu-latest - must use 20.04.  Update
  the python matrix to include the os to use as well.

  - Use checkout@v3 and setup-python@v4

  - python 3.11 stable is now supported by setup-python

  - Add `push` action for status reporting on role main page if missing

  - Use `docker` for ansible-test if not already doing that

[1.2.4] - 2022-09-01
--------------------

### New Features

- none

### Bug Fixes

- Replicate all provided databases (#110)
  - This change fixes the bug where only the first database provided with
mssql_ha_db_names got replicated
  - Clarify that the role does not remove not listed databases
- Input multiple sql scripts (#109)
  - Allow _input_sql_file vars to accept list of files
  - Flush handlers prior to inputting post sql script
- Note that ha_cluster is not idempotent (#111)

### Other Changes

- none

[1.2.3] - 2022-08-25
--------------------

### New Features

- none

### Bug Fixes

- Fix adding listener and creating test dbs (#107)
  - Add listener when mssql_ha_configure is true
  - tests: create test dbs by running the role

### Other Changes

- none

[1.2.2] - 2022-08-25
--------------------

### New Features

- Add mssql_ha_db_names to let users replicate multiple DBs
  - Replace mssql_ha_db_name with mssql_ha_db_names so that users can
    provide a list of databases to be replicated
  - Previously, a database must exist in SQL Server to create a cluster.
    Now mssql_ha_db_names is optional, if it is not provided the role
    creates a cluster without replicating databases
  - Remove mssql_ha_db_backup_path and always back up to the
    /var/opt/mssql/data/ directory for simplicity

- Remove `mssql_ha_firewall_configure`, rename `mssql_firewall_configure` to `mssql_manage_firewall` (#104)

  - Previously, two variables existed, `mssql_ha_firewall_configure` and
    `mssql_firewall_configure`. For simplicity, the role now only uses
    `mssql_firewall_configure` for configuring firewall.
  
  - s/mssql_firewall_configure/mssql_manage_firewall for consistency.
    `mssql_manage_firewall` makes more sense because firewall is a service and
    the word manage fits it better.
    Other system roles use the `rolename_manage_firewall` wording too and
    mssql must be consistent with them for simplicity

### Bug Fixes

- Fix HA on Azure example to set firewall and ha_cluster vars correctly (#103)

  - Fix HA on Azure example to set firewall port variable correctly

  - Fix Azure example to set `ha_cluster_extra_packages` port variable correctly

- Set mssql_ha_replica_type in defaults/main.yml

### Other Changes

- none


[1.2.1] - 2022-08-23
--------------------

### New Features

- Use firewall role to configure firewall for SQL Server (#77)
  - Add `mssql_firewall_configure` that controls whether to manage firewall ports.
  - If set to `true`, the role opens the TCP port provided with `mssql_tcp_port`
    and if applicable closes the previously opened port.

- Replace simple `mssql_input_sql_file` with `pre` and `post` variables (#84)
  - Previously, `mssql_input_sql_file` input SQL files at the end of the
    role invocation. However, users must input some SQL files at the
    beginning of the role before it applies any configuration to SQL Server.
    `mssql_pre_input_sql_file` and `mssql_post_input_sql_file` has been
    added to address this functionality.

- Replace agents in cluster configuration with watchdog (#83)
  - Change bare-metal HA example in README to use watchdog instead of agents
  - Unify vars in README and tests_configure_ha_cluster
  - tests_configure_ha_cluster - move variables to the top for readability

- Add prerequisite about DNS resolution to README (#87)

- README: Note that changing HA listener port number is not supported (#91)

- Add a prerequisites section for HA. (#96)

- Add mssql_ha_virtual_ip (#92)
  - Fix vars indentation in the example playbook
  - Add mssql_ha_virtual_ip
  - Add listeners to the availability group
  - Add tests for the new template
  - Update examples in README
  - In Azure example playbook add firewall role invocation and comments
  - Describe the requirement to define ha_cluster's names with short names
  - Note that witness can be set for max 1 host

### Bug Fixes

- Remove unnecessary quotes from yaml strings (#88)

- Remove tasks that verify HA setup (#93)
  - When running against VMs in beaker, the verification tasks failed
    because db replication requires more time.
    It's safer to remove verification tasks completely and leave
    verification on users

- s/System Roles role/fedora.linux_system_roles.role/ to avoid ambiguity (#94)

- README: fix URLs and xrefs markup (#97)

- Sort ansible_play_hosts to ensure configure_ag script runs smoothly (#98)

- Remove the workaround for `any_errors_fatal: true` (#100)
  - Previously, the role would use a workaround of setting a
    __mssql_primary_successful variable to define whether the primary node
    really failed or not. This was required because any_errors_fatal: true
    would not work when run in a block where rescue or always block would
    execute.
    This workaround creates troubles when the order of hosts in inventory is
    not primary-secondary-witness - the role skips a rescue block after
    failing tasks in the block on primary and goes to the next block.
    Removing the workardound for stability. Certificate and private key now
    won't be removed from the control node in the case of failure, but those
    files will be removed on a next successful role invocation.

### Other Changes

- Remove the tests/vars symlink for vars (#78)
  - ansible-test returns ERROR: tests/mssql/vars:0:0: broken symlinks are not allowed
    See documentation for help: https://docs.ansible.com/ansible-core/2.12/dev_guide/testing/sanity/symlinks.html

- Use GITHUB_REF_NAME as name of push branch; fix error in branch detection [citest skip]
  - We need to get the name of the branch to which CHANGELOG.md was pushed.
    For now, it looks as though `GITHUB_REF_NAME` is that name.  But don't
    trust it - first, check that it is `main` or `master`.  If not, then use
    a couple of other methods to determine what is the push branch.
    Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- tests_tls: generate certs on managed nodes to avoid installing local RPM (#82)

- Do not publish legacy role format to galaxy, mssql only has a collection (#89)

- [citest skip] tox-lsr 2.13.0; check-meta-versions (#90)
  - Update to tox-lsr 2.13.0 - this adds check-meta-versions to py310
    Signed-off-by: Rich Megginson <rmeggins@redhat.com>

[1.2.0] - 2022-07-11
--------------------

### New Features

- Add support for configuring HA cluster
- Add mssql_tls_remote_src

### Bug Fixes

- none

### Other Changes

- Use variable instead of hardcoded config file path
- Only gather required facts to save time

[1.1.1] - 2022-05-01
--------------------

### New Features

- Add mssql_rpm_key, mssql_server_repository, mssql_client_repository variables

### Bug Fixes

- none

### Other Changes

- Add an ansible_managed header to /var/opt/mssql/mssql.conf

[1.1.0] - 2021-07-01
--------------------

### New Features

- Add support for SQL Server 2017

### Bug Fixes

- none

### Other Changes

- none
