Changelog
=========

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
