Changelog
=========

[2.2.1] - 2024-01-29
--------------------

### Bug Fixes

- fix: Ensure selinux type for used ports (#253)

  Enhancement: Ensure SELinux type for used ports

  Reason: Custom TCP ports must have `mssql_port_t` SELinux type

  Result: When mssql_manage_selinux is set to `true`, the role configures used ports with the `mssql_port_t` SELinux type

- fix: Set default mode for data and log storage directories (#253)

  Enhancement: Set default mode for data and log storage directories 
  
  Reason: `mssql_datadir_mode` and `mssql_logdir_mode` should have a default value for security

  Result: `mssql_datadir_mode` and `mssql_logdir_mode` variables have a default value of `'755'`

### Other Changes

- ci: support ansible-lint and ansible-test 2.16 (#251)

  Fix yamllint issue with markdownlint config
  
  Add cleanup for tests_include_vars_from_parent.yml
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- ci: Use supported ansible-lint action; run ansible-lint against the collection (#252)

  The old ansible-community ansible-lint is deprecated.  There is a
  new ansible-lint github action.
  
  The latest Ansible repo gating tests run ansible-lint against
  the collection format instead of against individual roles.
  We have to convert the role to collection format before running
  ansible-test.
  
  This also requires tox-lsr 3.2.1 - bump other actions to use 3.2.1
  
  Role developers can run this locally using
  `tox -e collection,ansible-lint-collection`
  See https://github.com/linux-system-roles/tox-lsr/pull/125
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>


[2.2.0] - 2023-12-11
--------------------

### New Features

- feat: Add mssql_ha_prep_for_pacemaker for configuring HA solution other than Pacemaker (#245)

  Enhancement: Add the `mssql_ha_prep_for_pacemaker` variable to configure SQL Server for Pacemaker.
  
  Reason: Previously, the role did not have a variable to control whether to configure SQL Server for Pacemaker. Some users require to not configure for Pacemaker to use some custom HA solution.
  
  Result: You can use the `mssql_ha_prep_for_pacemaker` variable to configure SQL Server for Pacemaker.

### Bug Fixes

- fix: Remove no_log: true where it is not required (#241)

  Enhancement: Remove `no_log: true` where it is not required.
  
  Reason: `no_log: true` was set on `package_facts` and `service_facts` modules to have cleaner logs because the large output of this task is not helpful for logs. However, users might have issues with Ansible not able to run these modules e.g. because it is not able to find python interpreter, such issues were hard to troubleshoot with a hidden output.
  
  Result: Tasks that use `package_facts` and `service_facts` modules do not use `no_log: true`, hence they print output when running `ansible-playbook` with `-v`.
  
  Issue Tracker Tickets (Jira or BZ if any): Fixes #240

- fix: Remove unnecessary variable requirements for read-scale clusters (#242)

  Enhancement: Remove unnecessary variable requirements for read-scale clusters
  
  Reason: Read-scale clusters do not require creating users for Pacemaker and installing the `mssql-server-ha` package.
  
  Result: This remove a requirement for unnecessary variables when running a read-scale cluster and requirement to install the mssql-server-ha, which depends on packages from HA repository.

- fix: Manage selinux context for custom storage directories (#247)

  Enhancement: On RHEL 9, manage SELinux context for custom storage paths
  
  Reason: SQL Server runs on RHEL 9 as a SELinux-confined application and requires custom storage paths to have the correct SELinux context.
  
  Result: When user sets `mssql_manage_selinux: true`, the role configures directories provided with `mssql_logdir` and `mssql_datadir` with a proper SELinux context.

- fix: Use until instead of `wait_for` to retry when TCP errors occur (#247)
  
  Reason: The role used `wait_for` module to work around random TCP errors in `mssql-server`

  Result: Now the role uses the `until` loop to catch errors, which makes the roe much faster

### Other Changes

- chore: Use GA repository for RHEL 9 (#243)

  Enhancement: Use GA repository for RHEL 9
  
  Reason: Microsoft created a GA repository for RHEL 9 instead of the tech preview repository
  
  Result: On RHEL 9, mssql-server is taken from the GA repository instead of the preview repository.

- ci: bump actions/github-script from 6 to 7 (#246)

- refactor: get_ostree_data.sh use env shebang - remove from .sanity* (#248)

  Use the `#!/usr/bin/env bash` shebang which is ansible-test friendly.
  This means we can remove get_ostree_data.sh from the .sanity* files.
  This also means we can remove the .sanity* files if we do not need
  them otherwise.
  
  Rename `pth` to `path` in honor of nscott
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- chore: Deprecate mssql_ha_cluster_run_role for mssql_manage_ha_cluster (#249)

  Enhancement: Deprecate mssql_ha_cluster_run_role for mssql_manage_ha_cluster.
  
  Reason: System roles consistently use variables in the form `mssql_manage_<rolename>` for managing components with other system roles. This role already uses `mssql_manage_firewall` and `mssql_manage_selinux`. Renaming `mssql_ha_cluster_run_role` to `mssql_manage_ha_cluster` brings consistency to variables names.
  
  Result: When you set the deprecated `mssql_ha_cluster_run_role` variable, the role prints a message that this variable is deprecated and continues. 
  


[2.1.0] - 2023-11-20
--------------------

### New Features

- feat: Support mssql-server 2022 preview on RHEL 9 (#237)

  Enhancement: Support mssql-server 2022 preview on RHEL 9
  
  Reason: Microsoft added SQL Server 2022 preview for RHEL 9 at https://packages.microsoft.com/rhel/9/mssql-server-preview/
  
  Result: You can install SQL Server 2022 on RHEL 9
  
  Issue Tracker Tickets (Jira or BZ if any): https://issues.redhat.com/browse/RHELBU-2407

### Other Changes

- chore(deps): bump actions/checkout from 3 to 4 (#230)

  Bumps [actions/checkout](https://github.com/actions/checkout) from 3 to 4.

- ci: ensure dependabot git commit message conforms to commitlint (#233)

  Ensure dependabot git commit message conforms to commitlint
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- ci: use dump_packages.py callback to get packages used by role (#235)

  This adds the dump_packages.py callback which will dump the
  arguments to the `package` module (except for `state: absent`)
  to the integration test run logs.  The output looks like this:
  `lsrpackages: pkg-a pkg-b ...`
  We will have tooling which will scrape the logs to extract the
  packages used at runtime and testing for all of the supported
  combinations of distribution and version.
  
  This also ensures the weekly-ci PR git commit message conforms
  to commitlint.
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- ci: tox-lsr version 3.1.1 (#238)

  This is primarily for the update to ansible-plugin-scan to
  work with the upcoming ostree changes, but also includes
  some minor fixes which affect ci.
  3.1.0 was released but not used due to a bug fixed in 3.1.1
  See full release notes for 3.1.0 and 3.1.1
  https://github.com/linux-system-roles/tox-lsr/releases
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>


[2.0.3] - 2023-09-08
--------------------

### Other Changes

- docs: Make badges consistent, run markdownlint on all .md files (#227)

  - Consistently generate badges for GH workflows in README RHELPLAN-146921
  - Run markdownlint on all .md files
  - Add custom-woke-action if not used already
  - Rename woke action to Woke for a pretty badge
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>

- ci: Remove badges from README.md prior to converting to HTML (#228)

  - Remove thematic break after badges
  - Remove badges from README.md prior to converting to HTML
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>


[2.0.2] - 2023-08-16
--------------------

### Other Changes

- ci: Add markdownlint, test_converting_readme, and build_docs workflows (#224)

  - markdownlint runs against README.md to avoid any issues with
    converting it to HTML
  - test_converting_readme converts README.md > HTML and uploads this test
    artifact to ensure that conversion works fine
  - build_docs converts README.md > HTML and pushes the result to the
    docs branch to publish dosc to GitHub pages site.
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>

- docs: Update .collection/README.md (#225)

  Update information in a collection README


[2.0.1] - 2023-07-28
--------------------

### Other Changes

- ci: fix hardcoded domain name, it is randomized in IDM CI (#222)

  Enhancement: Fix hardcoded domain name, it is randomized in IDM CI
  
  Reason: ad_integration_realm is randomized in IDM CI hence need to use variables.
  Cannot use variable for Administrator because test with `mssql_ad_join: false` does `ad_integration_user: null`
  
  Result: Tests in IDM CI pass when run using trigger-test-suite-tool


[2.0.0] - 2023-07-27
--------------------

### New Features

- feat: Add mssql_ad_join and mssql_ad_kerberos_user to allow using other domain join methods (#211)

  Enhancement:
  1. Add the `mssql_ad_join` variable to allow using other domain join methods.
  2. Add the `mssql_ad_kerberos_user` and `mssql_ad_kerberos_password` variables to allow users to specify a user to obtain kerberos ticket for in the case that default user doesn't match.
  
  Reason: Sometimes, users use other methods to manage joining to AD that would be broken if that role were to run.
  
  Result:
  1. Users can set `mssql_ad_join` to `false` and join managed nodes to AD themselves prior to running the role. By default, `mssql_ad_join` = `true`, so the current behavior is not changed.
  2. Users can set `mssql_ad_kerberos_user` and `mssql_ad_kerberos_password` to obtain a kerberos ticket for a specific use if the user that the role selects by default doesn't work for them.
  
  Issue Tracker Tickets (Jira or BZ if any):
  Resolves #210 

- feat: Add mssql_ad_keytab_file to allow users provide a pre-created keytab (#214)

  Enhancement: Add `mssql_ad_keytab_file` and `mssql_ad_keytab_remote_src` variables to allow users to provide a pre-created keytab.
  
  Reason: Sometimes users do not want the role to access a privileged AD account with adutil to create the keytab within the role, but instead they receive a pre-created keytab file that they want to input to mssql-server.
  
  Result: Users can provide the keytab file with the `mssql_ad_keytab_file` variable according to an example playbook.

- feat: Add the ability to input T-SQL scripts content in addition to files (#218)

  Enhancement: Add the ability to add SQL scripts as a content directly.
  
  Reason: Previously, users could save SQL script to a file and input it with `mssql_pre_input_sql_file` and `mssql_post_input_sql_file`. Sometimes for shorter scripts it may be an overkill to create a separate file, and it would be easier to provide the script content to the role directly.
  
  Result: With this update, users can provide a T-SQL script directly with `mssql_pre_input_sql_content` and `mssql_post_input_sql_content` variables.

### Bug Fixes

- fix: Only do an upgrade if there is a current version (#208)

  Enhancement:
  Skip Prepare upgrade step if there is no current version
  
  Reason:
  Having `mssql_upgrade` enabled, while there is no current version installed failed with undefined variable `__mssql_current_version`. 
  
  Result:
  If no current version is installed, the prepare upgrade task is skipped and a fresh installation is done.

- fix: facts being gathered unnecessarily (#215)

  Cause: The comparison of the present facts with the required facts is
  being done on unsorted lists.
  
  Consequence: The comparison may fail if the only difference is the
  order.  Facts are gathered unnecessarily.
  
  Fix: Use `difference` which works no matter what the order is.  Ensure
  that the fact gathering subsets used are the absolute minimum required.
  
  Result: The role gathers only the facts it requires, and does
  not unnecessarily gather facts.
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- fix!: AD - Remove creating the privileged account login (#217)

  Enhancement: For AD integration - remove the functionality to automatically create privileged account login in SQL Server.
  
  Reason: This is required to ensure that the role does not create security leaks by silently creating accounts for users with admin permissions. Least privileged access and separation of duty are core security practices that the role should account.
  
  Result: The role now does not create any Active Directory-based SQL Server logins, users are now responsible for doing this and are informed about this in README.md.

### Other Changes

- ci: Implement proper cleanup.yml to run tests in series (#207)

  Enhancement: Add cleanup task to all tests 
  
  Reason: Our CI is now capable of running tests in series on a single node to make tests faster. This requires a cleanup 
  
  Result: Each test runs a complete cleanup of mssql and related services at it's end

- ci: Rename commitlint to PR title Lint, echo PR titles from env var (#209)

  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>

- ci: Ignore `var-naming[no-role-prefix] ` ansible-lint checks inline (#212)

  Enhancement: Ignore `var-naming[no-role-prefix] ` ansible-lint checks inline
  
  Reason: ansible-lint checks `var-naming[no-role-prefix] ` fail on some lines where the use of vars not starting with `mssql_` is required.
  
  Result: The checks are ignored on affected lines.

- ci: ansible-lint - ignore var-naming[no-role-prefix] (#213)

  ansible-lint has recently added a check for this.  It flags a lot of our test
  code, and some of our role code that uses nested roles.
  There is no easy way to disable it for these cases only.  It would be a
  tremendous amount of work to add `# noqa` comments everywhere.
  The use of `.ansible-lint-ignore` would be a maintenance burden (cannot use
  tests/tests_*.yml or other similar wildcard to match all test files), would
  still issue a lot of warning messages, and would not solve all of the problems.
  The only way for now is to skip this rule.
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- tests: tests_configure_ha_cluster add multi-node verification tasks (#216)

- docs:  Improve README titles indentation and fix syntax (#219)

  Enhancement:
  - Remove redundant title lvl indentation
  - Add syntax highlighting to all code blocks
  - Fix indentation in lists
  
  Reason: Improve README readability and fix syntax

- refactor: Deprecate mssql_ad_sql_user_name with mssql_ad_sql_user (#220)

  Enhancement: Deprecate the `mssql_ad_sql_user_name` variable, instead use the `mssql_ad_sql_user` variable for consistency with the `ad_integration_user` variable in the ad_integration system role and with other system roles. 
  
  Reason: Generally, system roles use the `_user` variable and not the `user_name`.
  
  Result: The previously used `mssql_ad_sql_user_name` is marked as deprecated, when one uses this variable, the role informs that it is deprecated and will be removed in a future release, still the variable works the same way. Documentation now uses the `mssql_ad_sql_user` variable. 


[1.4.1] - 2023-06-12
--------------------

### Bug Fixes

- fix: Remove outdated and confusing mssql_enable_ha variable (#204)

  It has a very limited functionality, the proper HA functionality is available with the mssql_ha_configure variable

### Other Changes

- tests: Keep cache in cleanup and rename for consistency (#203)

- ci: Add pull request template and run commitlint on PR title only (#205)

  We now ensure the conventional commits format only on PR titles and not on
  commits to let developers keep commit messages targeted for other developers
  i.e. describe actual changes to code that users should not care about.
  And PR titles, on the contrary, must be aimed at end users.
  
  For more info, see
  https://linux-system-roles.github.io/contribute.html#write-a-good-pr-title-and-description
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>


[1.4.0] - 2023-05-31
--------------------

### New Features

- feat: Support custom data and logs storage paths (#199)

  Previously, the role was configuring the default data and logs storage
  paths. Currently, you can provide custom storage paths with variables
  `mssql_datadir` and `mssql_logdir`, and optionally set permissions for
  the custom paths with `mssql_datadir_mode` and `mssql_logdir_mode`
  variables.

### Other Changes

- perf: Enable running in series (#182)

  * Split tests_upgrade to tests_2019_upgrade and tests_2022_upgrade
  
  * Replace tests_accept_eula_2019 with 2017
  
  * tests_tls: Clone for 2017 and 2022, disable encryption for future tests
  
  * Clone tests_tcp_firewall for all versions
  
  * Assert fail on RHEL 7 when upgrading to 2022 on new tests
  
  * Unset settings using format with dot between setting names
  
- ci: update tox-lsr to 2.13.2; update ansible-lint configuration; start of support for merge queues

  Update tox-lsr to 2.13.2
  
  Update ansible-lint configuration
  
  Add support for merge queues to github actions
  This doesn't mean all system roles support merge queues,
  this is just a preliminary step
  
  See https://github.com/linux-system-roles/.github/pull/21
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>
  
- docs: Add README-ansible.md to refer Ansible intro page on linux-system-roles.github.io

  Signed-off-by: Noriko Hosoi <nhosoi@redhat.com>
  
- chore: Fingerprint RHEL System Role managed config files (#185)

  - Add role name to the generated config files.
  
  Signed-off-by: Noriko Hosoi <nhosoi@redhat.com>
  
- ci: ansible-lint - use changed_when for conditional tasks; fix spacing (#186)

  ansible-lint now requires the use of changed_when even for
  conditional tasks
  
  - Fix some jinja spacing issues
  - add skip for `galaxy[no-runtime]`
  - remove deprecated suppression comment
  - add pipefail for shell
  - add yaml header for vault-variables.yml
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>
  
- ci: Add commitlint GitHub action to ensure conventional commits with feedback

  For more information, see Conventional Commits format in Contribute
  https://linux-system-roles.github.io/contribute.html#conventional-commits-format
  
  Signed-off-by: Sergei Petrosian <spetrosi@redhat.com>
  
- docs: Consistent contributing.md for all roles - allow role specific contributing.md section

  Provide a single, consistent contributing.md for all roles.  This mostly links to
  and summarizes https://linux-system-roles.github.io/contribute.html
  
  Allow for a role specific section which typically has information about
  role particulars, role debugging tips, etc.
  
  See https://github.com/linux-system-roles/.github/pull/19
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>
  
- ci: update tox-lsr to version 3.0.0

  The major version bump is because tox-lsr 3 drops support
  for tox version 2.  If you are using tox 2 you will need to
  upgrade to tox 3 or 4.
  
  tox-lsr 3.0.0 adds support for tox 4, commitlint, and ansible-lint-collection
  
  See https://github.com/linux-system-roles/tox-lsr/releases/tag/3.0.0
  for full release notes
  
  Signed-off-by: Rich Megginson <rmeggins@redhat.com>
  
- refactor: Refactor tests and fix tests timeouts (#201)

  * Print stdout and stderr for sqlcmd files input
  * Wait for mssql-server to start longer to avoid timeout
  * Put tests tasks in separate files to reuse for diff versions

[1.3.0] - 2023-02-16
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

- Rename mssql_ha_listener_port to mssql_ha_endpoint_port (#166)
  As per feedback from Microsoft, mssql_ha_listener_port should be called
  mssql_ha_endpoint_port, as that port is used
  when creating endpoint for replication between primary and secondary
  replica. Listener is a term used for AG listener associated with AG
  which is used to route client connection to primary replica (or read
  only secondary replica based on configuration and request type).
  And listener uses tcp_port, hence the confusion.

- Restructure README files to split it into available scenarios (#161)

- Add AD integration functionality (#159)
  - Add mssql version to set up
  - Add clean up for realm to clean_up_mssql.yml
  - Remove setting passwords with environment:
    Set password inline for security because setting passwords with
    environment: reveals the value when running playbooks with high
    verbosity
  - Add collection-requirements.yml
  - Set the mssql_password variable to default null after test verification
  - Add mssql_ad_netbios_name
  - Add mssql_ad_sql_user_dn variable for flexibility
  
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

- Add a note about not supporting direct upgrade 2017>2022 (#157)

- Fixes for AD integration functionality (#172)
  - Add configuring DNS vars to ad_integration
  - Install sshpass on client for AD testing
  - Print errors for tasks with no_log: true for visibility
  - Add tests/requirements.txt for reqs on Python modules during testing
  - Set up MSSQL in a separate block to catch errors

- Call the ad_integration role with FQDN (#175)

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

- ansible-lint 6.x fixes (#162)
  The big one is that ansible-lint doesn't like templates in `name`
  strings except at the end.  In general, Ansible does not like having
  templated variables in `name` values because it makes it harder to
  grep the source to find a log message in the source.
  The other ones are jinja spacing cleanup, use of `true`/`false`
  instead of `yes`/`no`, and various other cleanup.

- Add check for non-inclusive language (#158)
  - Cleanup non-inclusive words.
  - Add a check for usage of terms and language that is considered
    non-inclusive. We are using the woke tool for this with a wordlist
    that can be found at
    https://github.com/linux-system-roles/tox-lsr/blob/main/src/tox_lsr/config_files/woke.yml
  - Create separate github actions for various checks; get rid of monolithic tox.yml
    Using separate github actions, and especially the official github actions which
    generally have support for in-line comments, should help greatly with
    readability and troubleshooting test results.
  - skip no-changelog errors because it searches changelog in .collection
    galaxy[no-changelog]: No changelog found. Please add a changelog file.
    Refer to the galaxy.md file for more info.
    .collection/galaxy.yml:1

- Skip no-changed-when check in clean_up.yml (#171)
  - add contents: write permission for branch push
  - Need `contents: write` permission for branch push for weekly ci job
    Signed-off-by: Rich Megginson <rmeggins@redhat.com>

- Remove shellcheck github action (#173)
  Remove shellcheck github action since there are no shell scripts in the role.

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
