# Microsoft SQL Server

[![ansible-lint.yml](https://github.com/linux-system-roles/mssql/actions/workflows/ansible-lint.yml/badge.svg)](https://github.com/linux-system-roles/mssql/actions/workflows/ansible-lint.yml) [![ansible-test.yml](https://github.com/linux-system-roles/mssql/actions/workflows/ansible-test.yml/badge.svg)](https://github.com/linux-system-roles/mssql/actions/workflows/ansible-test.yml) [![markdownlint.yml](https://github.com/linux-system-roles/mssql/actions/workflows/markdownlint.yml/badge.svg)](https://github.com/linux-system-roles/mssql/actions/workflows/markdownlint.yml) [![tft.yml](https://github.com/linux-system-roles/mssql/actions/workflows/tft.yml/badge.svg)](https://github.com/linux-system-roles/mssql/actions/workflows/tft.yml) [![tft_citest_bad.yml](https://github.com/linux-system-roles/mssql/actions/workflows/tft_citest_bad.yml/badge.svg)](https://github.com/linux-system-roles/mssql/actions/workflows/tft_citest_bad.yml) [![woke.yml](https://github.com/linux-system-roles/mssql/actions/workflows/woke.yml/badge.svg)](https://github.com/linux-system-roles/mssql/actions/workflows/woke.yml)

This role installs, configures, and starts Microsoft SQL Server.

The role also optimizes the operating system to improve performance and throughput for SQL Server by applying the `mssql` Tuned profile.

## Requirements

* SQL Server requires a machine with at least 2000 megabytes of memory.
* Optional: If you want to input T-SQL statements and stored procedures to SQL Server, you must create a file with the `.sql` extension containing these SQL statements and procedures.

## Configuring General SQL Server Settings

These variables apply to general SQL Server configuration.

### General Settings Variables

#### mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula

Set this variable to `true` to indicate that you accept EULA for installing the `msodbcsql17` package.

The license terms for this product can be downloaded from <https://aka.ms/odbc17eula> and found in `/usr/share/doc/msodbcsql17/LICENSE.txt`.

Default: `false`

Type: `bool`

#### mssql_accept_microsoft_cli_utilities_for_sql_server_eula

Set this variable to `true` to indicate that you accept EULA for installing the `mssql-tools` package.

The license terms for this product can be downloaded from <http://go.microsoft.com/fwlink/?LinkId=746949> and found in `/usr/share/doc/mssql-tools/LICENSE.txt`.

Default: `false`

Type: `bool`

#### mssql_accept_microsoft_sql_server_standard_eula

Set this variable to `true` to indicate that you accept EULA for using Microsoft SQL Server.

The license terms for this product can be found in `/usr/share/doc/mssql-server` or downloaded from <https://go.microsoft.com/fwlink/?LinkId=2104078&clcid=0x409>.
The privacy statement can be viewed at <https://go.microsoft.com/fwlink/?LinkId=853010&clcid=0x409>.

Default: `false`

Type: `bool`

#### mssql_password

The password for the database sa user.
The password must have a minimum length of 8 characters, include uppercase and lowercase letters, base 10 digits or non-alphanumeric symbols.
Do not use single quotes ('), double quotes ("), and spaces in the password because `sqlcmd` cannot authorize when the password includes those symbols.

This variable is required when you run the role to install SQL Server.

When running this role on a host that has SQL Server installed, the `mssql_password` variable overwrites the existing sa user password to the one that you specified.

Default: `null`

Type: `string`

#### mssql_edition

The edition of SQL Server to install.

This variable is required when you run the role to install SQL Server.

Use one of the following values:

* `Enterprise`
* `Standard`
* `Web`
* `Developer`
* `Express`
* `Evaluation`
* A product key in the form `#####-#####-#####-#####-#####`, where `#` is a number or a letter.
  For more information, see [Configure SQL Server settings with environment variables on Linux](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-ver16).

Default: `null`

Type: `string`

#### mssql_enable_sql_agent

Optional: Set this variable to `true` or `false` to enable or disable the SQL agent.

Default: `null`

Type: `bool`

#### mssql_tune_for_fua_storage

Optional: Set this variable to `true` or `false` to enable or disable settings that improve performance on hosts that support Forced Unit Access (FUA) capability.

Only set this variable to `true` if your hosts are configured for FUA capability.

When set to `true`, the role applies the following settings:

* Set the `traceflag 3979 on` setting to enable trace flag 3979 as a startup parameter
* Set the `control.alternatewritethrough` setting to `0`
* Set the `control.writethrough` setting to `1`

When set to `false`, the role applies the following settings:

* Set the `traceflag 3982 off` parameter to disable trace flag 3979 as a startup parameter
* Set the `control.alternatewritethrough` setting to its default value `0`
* Set the `control.writethrough` setting to its default value `0`

For more details, see SQL Server and Forced Unit Access (FUA) I/O subsystem capability at [Performance best practices and configuration guidelines for SQL Server on Linux](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-performance-best-practices?view=sql-server-ver15).

Default: `null`

Type: `bool`

### General Settings Example Playbooks

#### Configuring Basic SQL Server

This example playbook shows how to use the role to configure SQL Server with the minimum required variables.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
  roles:
    - microsoft.sql.server
```

## Managing SQL Server version

Use these variables to manage SQL Server version.

### Managing Version Considerations

* The role does not support downgrading SQL Server.
* SQL Server does not support a direct upgrade from 2017 to 2022.
  To upgrade from 2017 to 2022, you must perform the upgrade in two steps - upgrade 2017 to 2019 and then 2019 to 2022.
* SQL Server 2022 does not support EL 7 hosts.
* The role currently supports installing and configuring SQL Server versions 2017, 2019, and 2022.

### Managing Version Variables

#### mssql_version

The version of the SQL Server to configure.

The role currently supports installing and configuring SQL Server versions 2017, 2019, and 2022.

If unset, the role sets the variable to the currently installed SQL Server version.

Note that RHEL 7 does not support SQL Server 2022.

Default: `null`

Type: `int`

#### mssql_upgrade

Optional: If you want to upgrade your SQL Server, set this variable to `true` and the `mssql_version` variable to the version to which you wish to upgrade.

Default: `false`

Type: `bool`

## Configuring SQL Server as a Confined Application (EL 9)

Optional: SQL Server on RHEL 9 supports running as a confined application with SELinux enabled.
For more information, see [Install SQL Server on RHEL 9](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-red-hat?view=sql-server-ver16&tabs=rhel9).

You can use the role to configure SELinux with the `enforcing` mode and install the `mssql-server-selinux` package.

**WARNING**: SQL Server supports this functionality only on RHEL 9 running SQL Server version 2022.

### Configuring SQL Server as a Confined Application Variables

#### mssql_run_selinux_confined

Whether to run SQL Server as a confined application or not.

* If set to `true`, the role installs the `mssql-server-selinux` package.
* If set to `false`, the role removes the `mssql-server-selinux` package.

Default: `true` for RHEL 9 managed nodes
         `false` for not RHEL 9 managed nodes

Type: `bool`

#### mssql_manage_selinux

Only applicable on RHEL 9 when running as a SELinux-confined application.

Whether to manage SELinux.

When set to `true`, configures the following SELinux contexts and settings:

1. Ensures the `mssql_port_t` SELinux port type for [mssql_tcp_port](#mssql_tcp_port).
2. When you define [mssql_datadir](#mssql_datadir) or [mssql_logdir](#mssql_logdir), configures SELinux context `mssql_db_t` for [mssql_datadir](#mssql_datadir) and `mssql_var_t` for [mssql_logdir](#mssql_logdir).
3. When you set [mssql_ha_configure](#mssql_ha_configure) to `true`, ensures the `mssql_port_t` SELinux port type [mssql_ha_endpoint_port](#mssql_ha_endpoint_port).

Default: `false`

Type: `bool`

### Configuring SQL Server as a Confined Application Example Playbook

Run the following playbook against a RHEL 9 system role to configure SQL Server as a confined application.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2022
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_run_selinux_confined: true
    mssql_manage_selinux: true
```

## Inputting SQL Scripts to SQL Server

Optional: You can use the role to input T-SQL statements or procedures into SQL Server.

You can either input a file containing T-SQL code or the code directly.
You can use on of the following methods:

1. With [mssql_pre_input_sql_file and mssql_post_input_sql_file](#mssql_pre_input_sql_file-and-mssql_post_input_sql_file), you can input a file containing T-SQL code.
2. With [mssql_pre_input_sql_content and mssql_post_input_sql_content](#mssql_pre_input_sql_content-and-mssql_post_input_sql_content), you can input T-SQL code directly.

When specifying any of these variables, you must also specify the `mssql_password` variable because authentication is required to input an SQL file to SQL Server.

Note that the input task is not idempotent, the role always inputs an SQL file if any of these variables is defined.

You can find an example of an SQL script at the role's `tests/files` directory.

### Inputting SQL Scripts Variables

#### mssql_input_sql_file

This variable is deprecated. Use the below variables instead.

#### mssql_pre_input_sql_file and mssql_post_input_sql_file

With these variables, enter the path to the files containing SQL scripts.

* Use `mssql_pre_input_sql_file` to input the SQL file immediately after the role configures SQL Server.
* Use `mssql_post_input_sql_file` to input the SQL file at the end of the role invocation.

You can set these variables to a list of files, or to a string containing a single file.

Default: `null`

Type: `string` or `list`

#### mssql_pre_input_sql_content and mssql_post_input_sql_content

With these variables, enter SQL scripts directly.

* Use `mssql_pre_input_sql_content` to input SQL scripts immediately after the role configures SQL Server.
* Use `mssql_post_input_sql_content` to input SQL scripts at the end of the role invocation.

You can set these variables to a list of scripts, or to a string containing a single script.

Default: `null`

Type: `string` or `list`

#### mssql_debug

Whether to print the output of sqlcmd commands when inputting T-SQL statements and procedures.

Default: `false`

Type: `bool`

### Inputting SQL Scripts Example Playbooks

#### Inputting SQL script files and content to SQL Server

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_pre_input_sql_file: script0.sql
    mssql_post_input_sql_file:
      - script1.sql
      - script2.sql
    mssql_pre_input_sql_file: |-
      USE master;
      IF NOT EXISTS (
        SELECT name FROM sys.server_principals
        WHERE name = '<mydomain>\<myADlogin>'
      )
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login does not exist, creating';
        CREATE LOGIN [<mydomain>\<myADlogin>] FROM WINDOWS;
        PRINT 'The <mydomain>\<myADlogin> login created successfully';
      END
      ELSE
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login already exists, skipping'
      END
    mssql_post_input_sql_file:
      - CREATE DATABASE ExampleDB1
      - |-
        IF NOT EXISTS(
          SELECT name
          FROM sys.databases
          WHERE name = 'ExampleDB2'
        )
        BEGIN
          PRINT 'Creating the ExampleDB2 database';
          CREATE DATABASE ExampleDB2;
          PRINT 'The ExampleDB2 database created successfully';
        END
        ELSE
        BEGIN
          PRINT 'The ExampleDB2 database already exists, skipping';
        END
        GO
```

## Installing Additional Packages

Optional: Use these variables to install additional packages to SQL Server host.

### Additional Packages Variables

#### mssql_install_fts

Set this variable to `true` or `false` to install or remove the `mssql-server-fts` package that provides full-text search.

Default: `null`

Type: `bool`

#### mssql_install_powershell

Set this variable to `true` or `false` to install or remove the `powershell` package that provides PowerShell.

Default: `null`

Type: `bool`

## Configuring Custom URLs for Packages

Optional: Use these variables to configure your host to get packages from custom URLs.
This is useful if you store packages in a proxy server.

When you do not provide these variables, the role uses default values from the `vars/` directory based on operating system.

### Custom URLs Variables

#### mssql_rpm_key

The URL or path to the Microsoft rpm gpg keys.

Default: `https://packages.microsoft.com/keys/microsoft.asc`

Type: `string`

#### mssql_server_repository

The URL to the Microsoft SQL Server repository.

Default: `{{ __mssql_server_repository }}`

Type: `string`

#### mssql_client_repository

The URL to the Microsoft production repository.

Default: `{{ __mssql_client_repository }}`

Type: `string`

## Configuring Custom Data and Logs Storage Paths

Optional: Use these variables to configure SQL Server to store data and logs in custom paths.

### Custom Paths Variables

Use these variables to configure custom storage paths.

On RHEL 9, you can set [mssql_manage_selinux](#mssql_manage_selinux) to `true` to set a correct SELinux context for custom directories.

#### mssql_datadir

The path to the directory that SQL Server must use to store data.
When defined, the role creates the provided directory and ensures correct permissions and ownership for it.

Note that if you change this path, the previously used directory and all it's content remains at the original path.

Default: `null`

Type: `string`

#### mssql_datadir_mode

The permissions to be set for the `mssql_datadir` path in the format of the Ansible `file` module `mode` variable.

Quote the mode like `'755'` so Ansible parses it as a string to avoid conflicts with octal numbers.

Default: `'755'`

Type: `string`

#### mssql_logdir

The path to the directory that SQL Server must use to store logs.
When defined, the role creates the provided directory and ensures correct permissions and ownership for it.

Note that if you change this path, the previously used directory and all it's content remains at the original path.

Default: `null`

Type: `string`

#### mssql_logdir_mode

The permissions to be set for the `mssql_logdir` path in the format of the Ansible `file` module `mode` variable.

Quote the mode like `'755'` so Ansible parses it as a string to avoid conflicts with octal numbers.

Default: `'755'`

Type: `string`

## Configuring Network Parameters

Use these variables to configure TCP port settings.

### Network Parameters Variables

#### mssql_ip_address

The IP address that SQL Server listens on.

If you define this variable, the role configures SQL Server with the defined IP address.

If you do not define this variable when installing SQL Server, the role configures SQL Server to listen on the SQL Server default IP address `0.0.0.0`, that is, to listen on every available network interface.

If you do not define this variable when configuring running SQL Server, the role does not change the IP address setting on SQL Server.

Default: `null`

Type: `string`

#### mssql_tcp_port

The port that SQL Server listens on.

If you set `mssql_manage_firewall` to `false`, you must open the firewall port defined with the `mssql_tcp_port` variable prior to running this role.

You can change the TCP port by setting this variable to a different port.
If you set `mssql_manage_firewall` to `true` while changing the TCP port, the role closes the previously opened firewall port.

Default: `1433`

Type: `int`

#### mssql_manage_firewall

Whether to open firewall ports required by this role.

When this variable is set to `true`, the role enables firewall even if it was not enabled.

The role uses the `fedora.linux_system_roles.firewall` role to manage the firewall, hence, only firewall implementations supported by the `fedora.linux_system_roles.firewall` role work.

If you set this variable to `false`, you must open required ports prior to running this role.

Default: `false`

Type: `bool`

### Network Parameters Example Playbooks

#### Configuring SQL Server with Custom Network Parameters

This example shows how to use the role to configure SQL Server, configure it with a custom IP address and TCP port, and open the TCP port in firewall.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_tcp_port: 1433
    mssql_ip_address: 0.0.0.0
    mssql_manage_firewall: true
  roles:
    - microsoft.sql.server
```

## Configuring TLS Certificates

Use the variables starting with the `mssql_tls_` prefix to configure SQL Server to encrypt connections using TLS certificates.

You can either use existing TLS certificate and private key files by providing them with [mssql_tls_cert` and `mssql_tls_private_key](#mssql_tls_cert-and-mssql_tls_private_key), or use the role to create certificates by providing [mssql_tls_certificates](#mssql_tls_certificates).

### TLS Certificates Variables

#### mssql_tls_enable

Set to `true` or `false` to enable or disable TLS encryption.

When set to `true`, the role performs the following tasks:

1. Copies or generates TLS certificate and private key files in `/etc/pki/tls/certs/` and `/etc/pki/tls/private/` directories respectively
2. Configures SQL Server to encrypt connections using TLS certificate and private key

When set to `false`, the role configures SQL Server to not use TLS encryption.
The role does not remove the existing certificate and private key files if this variable is set to `false`.

Default: `null`

Type: `bool`

#### mssql_tls_certificates

Use this variable to generate certificate and private key for TLS encryption using the `fedora.linux_system_roles.certificate`.

The value of `mssql_tls_certificates` is set to the variable `certificate_requests`
in the `certificate` role.
For more information, see the `certificate_requests` section in the `certificate` role documentation.

The following example generates a certificate FILENAME.crt in `/etc/pki/tls/certs` and a key FILENAME.key in `/etc/pki/tls/private`.

```yaml
mssql_tls_certificates:
  - name: FILENAME
    dns: *.example.com
    ca: self-sign
```

When you set this variable, you must not set `mssql_tls_cert` and `mssql_tls_private_key` variables.

Default: `[]`

Type: `list of dictionaries`

#### mssql_tls_cert and mssql_tls_private_key

Paths to the certificate and private key files to copy to SQL Server.

You are responsible for creating and securing TLS certificate and private key files.
It is assumed you have a CA that can issue these files.

When you use these variables, the role copies TLS cert and private key files to SQL Server and configures SQL Server to use these files to encrypt connections.

Default: `null`

Type: `string`

#### mssql_tls_remote_src

Only applicable when using [mssql_tls_cert` and `mssql_tls_private_key](#mssql_tls_cert-and-mssql_tls_private_key).

Influence whether files provided with `mssql_tls_cert` and `mssql_tls_private_key` need to be transferred or already are present remotely.

If `false`, the role searches for `mssql_tls_cert` and `mssql_tls_private_key` files on the controller node.

If `true`, the role searches for `mssql_tls_cert` and `mssql_tls_private_key` on managed nodes.

Default: `false`

Type: `bool`

#### mssql_tls_version

TLS version to use.

Default: `1.2`

Type: `string`

#### mssql_tls_force

Set to `true` to replace the existing certificate and private key files on host if they exist at `/etc/pki/tls/certs/` and `/etc/pki/tls/private/` respectively.

Default: `false`

Type: `bool`

### TLS Certificates Example Playbooks

#### Configuring SQL Server with TLS Encryption with Certificate Files

This example shows how to use the role to configure SQL Server and configure it to use TLS encryption.
Certificate files `mycert.pem` and `mykey.key` must exist on the primary node.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_tls_enable: true
    mssql_tls_cert: mycert.pem
    mssql_tls_private_key: mykey.key
    mssql_tls_version: 1.2
    mssql_tls_force: false
  roles:
    - microsoft.sql.server
```

#### Configuring SQL Server with TLS Encryption with the Certificate Role

This example shows how to use the role to configure SQL Server and configure it with TLS encryption using self-signed certificate and key created by the certificate role.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_tls_enable: true
    mssql_tls_certificates:
      - name: cert_name
        dns: *.example.com
        ca: self-sign
  roles:
    - microsoft.sql.server
```

## Configuring Always On Availability Group

Use the variables starting with the `mssql_ha_` prefix to configure an SQL Server Always On availability group to provide high availability.

Configuring for high availability is not supported on RHEL 7 because the `fedora.linux_system_roles.ha_cluster` role does not support RHEL 7.

### Always On Availability Group Prerequisites

* Ensure that your hosts meet the requirements for high availability configuration, namely DNS resolution configured so that hosts can communicate using short names.
  For more information, see Prerequisites in [Configure SQL Server Always On Availability Group for high availability on Linux](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-availability-group-configure-ha?view=sql-server-ver15#prerequisites).
* Optional: In SQL Server, create one or more databases to be used for replication.
  Provide databases names to the role with the [mssql_ha_db_names](#mssql_ha_db_names) variable.
  You can set the [mssql_pre_input_sql_file](#mssql_pre_input_sql_file-and-mssql_post_input_sql_file) variable to pre-create databases.
  For more information, see the description of the [mssql_ha_db_names](#mssql_ha_db_names) variable.

  If you do not provide the [mssql_ha_db_names](#mssql_ha_db_names) variable, the role creates a cluster without replicating database in it.

### Configuring the Ansible Inventory

You must set the `mssql_ha_replica_type` variable for each host that you want to configure.

If you set [mssql_manage_ha_cluster](#mssql_manage_ha_cluster) to `true`, you can provide variables required by the `fedora.linux_system_roles.ha_cluster` role.
If you do not provide names or addresses, the `fedora.linux_system_roles.ha_cluster` uses play's targets, and the high availability setup requires pacemaker to be configured with short names.
Therefore, if you define hosts in inventory not by short names, or the default hosts' IP address differs from the IP address that pacemaker must use, you must set the corresponding `fedora.linux_system_roles.ha_cluster` role variables.

For an example inventory, see [Example Inventory for HA Configuration](#example-inventory-for-ha-configuration).

See the `fedora.linux_system_roles.ha_cluster` role's documentation for more information.

### Always On Availability Group Variables

#### mssql_ha_configure

Set to `true` to configure for high availability.
Setting to `false` does not remove configuration for high availability.

When set to `true`, the role performs the following tasks:

1. Include the `fedora.linux_system_roles.firewall` role to configure firewall.
    1. Open the firewall port set with the [mssql_ha_endpoint_port](#mssql_ha_endpoint_port) variable.
    2. Enable the `high-availability` service in firewall.
2. Configure SQL Server for high availability.
    1. Enable AlwaysOn Health events.
    2. Create certificate on the primary replica and distribute to other replicas.
    3. Configure endpoint.
    4. Configure availability group with the type based on the value of the [mssql_ha_ag_cluster_type](#mssql_ha_ag_cluster_type) variable.
    5. Join nodes to the configured availability group.
3. When `mssql_ha_prep_for_pacemaker = true`: Configure nodes for Pacemaker.
    1. Install the `mssql-server-ha` package.
    2. Configure the user provided with the [mssql_ha_login](#mssql_ha_login) variable for
      Pacemaker.
    3. Configure virtual IP.
4. When [`mssql_manage_ha_cluster`](#mssql_manage_ha_cluster)`=true`: Include the `fedora.linux_system_roles.ha_cluster` role to configure Pacemaker.
  You must set [mssql_manage_ha_cluster](#mssql_manage_ha_cluster) to `true` and provide all variables required by the `fedora.linux_system_roles.ha_cluster` role for a proper Pacemaker cluster configuration based on example playbooks in [Always On Availability Group Example Playbooks](#always-on-availability-group-example-playbooks).

Default: `false`

Type: `bool`

#### mssql_ha_ag_cluster_type

With this variable, provide a cluster type that you want to configure.

You can set this variable to either `external` or `none`:

* When set to `external`, role configures Always On availability group for high availability with Pacemaker as described in [Configure SQL Server Always On Availability Group for high availability on Linux](https://learn.microsoft.com/en-us/sql/linux/)
* When set to `none`, role configures Always On availability group for read-scale without Pacemaker as described in [Configure a SQL Server Availability Group for read-scale on Linux](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-availability-group-configure-rs?view=sql-server-ver15)

Default: `external`

Type: `string`

#### mssql_ha_replica_type

A host variable that specifies the type of the replica to be configured on this host.

See [Example Inventory for HA Configuration](#example-inventory-for-ha-configuration) for an example inventory.

The available values are: `primary`, `synchronous`, `asynchronous`, `witness`.

You must set this variable to `primary` for exactly one host.

You can set this variable to `witness` for maximum one host.

Default: no default

Type: `string`

#### mssql_ha_endpoint_port

The TCP port used to replicate data for an Always On availability group.

Note that due to an SQL Server limitation it is not possible to change an endpoint port number on an existing availability group when the availability group contains a configuration-only replica.
To do that, you must re-create the availability group using the required port number.

If you set `mssql_manage_firewall` to `false`, you must open the firewall port defined with the `mssql_ha_endpoint_port` variable prior to running this role.

Default: `5022`

Type: `int`

#### mssql_ha_cert_name

The name of the certificate used to secure transactions between members of an Always On availability group.

Default: `null`

Type: `string`

#### mssql_ha_master_key_password

The password to set for the master key used with the certificate.

Default: `null`

Type: `string`

#### mssql_ha_private_key_password

The password to set for the private key used with the certificate.

Default: `null`

Type: `string`

#### mssql_ha_reset_cert

Whether to reset certificates used by an Always On availability group or not.

Default: `false`

Type: `bool`

#### mssql_ha_endpoint_name

The name of the endpoint to be configured.

Default: `null`

Type: `string`

#### mssql_ha_ag_name

The name of the availability group to be configured.

Default: `null`

Type: `string`

#### mssql_ha_db_names

This is an optional variable.

You can set this variable to the list of names of one or more existing SQL databases to replicate these database in the cluster.
The role backs up databases provided if no back up newer than 3 hours exists to the `/var/opt/mssql/data/` directory.

If you do not provide this variable when configuring new SQL Server, the role creates a cluster without replicating databases in it.

The role does not remove databases not listed with this variable from existing SQL Server clusters.

You can write a T-SQL script that creates database and feed it into the role with the [mssql_pre_input_sql_file](#mssql_pre_input_sql_file-and-mssql_post_input_sql_file) variable.
This way, the role runs your script to create databases after ensuring that SQL Server is running and then replicate these databases for high availability.

For example, you can write a `create_example_db.sql` SQL script that creates a test database and feed it into the SQL Server from the primary replica with `mssql_pre_input_sql_file` prior to running the role.

```yaml
- name: Set facts to create a test DB on primary as a pre task
  set_fact:
    mssql_pre_input_sql_file: create_example_db.sql
  when: mssql_ha_replica_type == 'primary'

- name: Run on all hosts to configure HA cluster
  include_role:
    name: microsoft.sql.server
```

Default: `[]`

Type: `list`

### Configuring Pacemaker Variables

With these variables, you can specify whether to configure Pacemaker HA solution and its configuration.

Only applicable when you set `mssql_ha_ag_cluster_type` to `external`.

#### mssql_ha_prep_for_pacemaker

Whether to configure SQL Server for Pacemaker.

If set to `true`, the role does the following configuration:

1. Configures Virtual IP in SQL Server
2. Creates a user for Pacemaker in SQL Server
3. Stores credentials for the Pacemaker user in `/var/opt/mssql/secrets/passwd`
4. Runs the `fedora.linux_system_roles.ha_cluster` role to configure Pacemaker

Default: `true`

Type: `bool`

#### mssql_ha_virtual_ip

The virtual IP address to be configured for the SQL cluster.

The role creates an availability group listener using the following values:

* The port provided with the `mssql_tcp_port` variable,
* The IP address provided with the `mssql_ha_virtual_ip` variable
* The `255.255.255.0` subnet mask

Default: `null`

Type: `string`

#### mssql_ha_login

The user created for Pacemaker in SQL Server.
This user is used by the SQL Server Pacemaker resource agent to connect to SQL Server to perform regular database health checks and manage state transitions from replica to primary when needed.

Default: `null`

Type: `string`

#### mssql_ha_login_password

The password for the mssql_ha_login user in SQL Server.

Default: `null`

Type: `string`

#### mssql_manage_ha_cluster

Whether to run the `fedora.linux_system_roles.ha_cluster` role from this role.

Note that the `fedora.linux_system_roles.ha_cluster` role has the following limitations:

* This role replaces the configuration of HA Cluster on specified nodes.
  Any settings not specified in the role variables will be lost.
* This role is not idempotent - it always returns changed state.

To work around this limitation, the `microsoft.sql.server` role does not set any variables for the `fedora.linux_system_roles.ha_cluster` role to ensure that any existing Pacemaker configuration is not re-written.

If you want the `microsoft.sql.server` to run the `fedora.linux_system_roles.ha_cluster` role, set `mssql_manage_ha_cluster: true` and provide variables for the `fedora.linux_system_roles.ha_cluster` role with the `microsoft.sql.server` role invocation based on example playbooks in [Always On Availability Group Example Playbooks](#always-on-availability-group-example-playbooks).

If you do not want the `microsoft.sql.server` to run the `fedora.linux_system_roles.ha_cluster` role and instead want to run the `fedora.linux_system_roles.ha_cluster` role independently of the `microsoft.sql.server` role, set `mssql_manage_ha_cluster: false`.

Default: `false`

Type: `bool`

### Always On Availability Group Example Playbooks

Examples in this section show how to use the role to configure SQL Server and configure it for high availability in different environments.

#### Example Inventory for HA Configuration

The following example inventory describes different cases:

```yaml
all:
  hosts:
    # host1 is defined by a short name
    # There is no need to specify ha_cluster names explicitly
    host1:
      mssql_ha_replica_type: primary
    # host2 and host3 is defined by FQDN
    # You must define ha_cluster names to be in the short name format
    host2.example.com:
      mssql_ha_replica_type: synchronous
      ha_cluster:
        node_name: host2
        pcs_address: host2
    host3.example.com:
      mssql_ha_replica_type: asynchronous
      ha_cluster:
        node_name: host3
        pcs_address: host3
    # host4 is defined by an ip address
    # You must define ha_cluster names to be in the short name format
    # In the case where the default host's IP address differs from the IP
    # address that Pacemaker must use to configure up cluster, you must define
    # ha_cluster corosync_addresses
    192.XXX.XXX.333:
      mssql_ha_replica_type: witness
      ha_cluster:
        node_name: host4
        pcs_address: host4
        corosync_addresses:
          - 10.XXX.XXX.333
```

#### Configuring SQL Server with a `none` Cluster Type for Read-scale without Pacemaker

Use the following example to configure SQL Server Always On for read-scale.
In this case, the role does not configure Pacemaker.

Inventory:

```yaml
all:
  hosts:
    client-mssql-1:
      ansible_host: <IP or FQDN>
      mssql_ha_replica_type: primary
    client-mssql-2:
      ansible_host: <IP or FQDN>
      mssql_ha_replica_type: asynchronous
    client-mssql-3:
      ansible_host: <IP or FQDN>
      mssql_ha_replica_type: asynchronous
```

Playbook:

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2022
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_ha_configure: true
    mssql_ha_ag_cluster_type: none
    mssql_ha_endpoint_port: 5022
    mssql_ha_cert_name: ExampleCert
    mssql_ha_master_key_password: "p@55w0rD1"
    mssql_ha_private_key_password: "p@55w0rD2"
    mssql_ha_reset_cert: false
    mssql_ha_endpoint_name: Example_Endpoint
    mssql_ha_ag_name: ExampleAG
    mssql_ha_db_names:
      - ExampleDB1
      - ExampleDB2
  roles:
    - microsoft.sql.server
```

#### Configuring SQL Server with HA and Pacemaker on Bare Metal

If you want to configure Pacemaker from this role, you can set [mssql_manage_ha_cluster](#mssql_manage_ha_cluster) to `true` and provide variables required by the `fedora.linux_system_roles.ha_cluster` role to configure Pacemaker for your environment properly.

This example configures required Pacemaker properties and resources and enables SBD watchdog.

The `fedora.linux_system_roles.ha_cluster` role expects watchdog devices to be configured on `/dev/watchdog` by default, you can set a different device per host in inventory.
For more information, see the `fedora.linux_system_roles.ha_cluster` role documentation.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_ha_configure: true
    mssql_ha_ag_cluster_type: external
    mssql_ha_endpoint_port: 5022
    mssql_ha_cert_name: ExampleCert
    mssql_ha_master_key_password: "p@55w0rD1"
    mssql_ha_private_key_password: "p@55w0rD2"
    mssql_ha_reset_cert: false
    mssql_ha_endpoint_name: Example_Endpoint
    mssql_ha_ag_name: ExampleAG
    mssql_ha_db_names:
      - ExampleDB1
      - ExampleDB2
    mssql_ha_login: ExampleLogin
    mssql_ha_login_password: "p@55w0rD3"
    mssql_ha_virtual_ip: 192.XXX.XXX.XXX
    mssql_manage_ha_cluster: true
    ha_cluster_cluster_name: "{{ mssql_ha_ag_name }}"
    ha_cluster_hacluster_password: "p@55w0rD4"
    ha_cluster_sbd_enabled: true
    ha_cluster_cluster_properties:
      - attrs:
          - name: cluster-recheck-interval
            value: 2min
          - name: start-failure-is-fatal
            value: true
          - name: stonith-enabled
            value: true
          - name: stonith-watchdog-timeout
            value: 10
    ha_cluster_resource_primitives:
      - id: ag_cluster
        agent: ocf:mssql:ag
        instance_attrs:
          - attrs:
              - name: ag_name
                value: "{{ mssql_ha_ag_name }}"
        meta_attrs:
          - attrs:
              - name: failure-timeout
                value: 60s
      - id: virtualip
        agent: ocf:heartbeat:IPaddr2
        instance_attrs:
          - attrs:
              - name: ip
                value: "{{ mssql_ha_virtual_ip }}"
        operations:
          - action: monitor
            attrs:
              - name: interval
                value: 30s
    ha_cluster_resource_clones:
      - resource_id: ag_cluster
        promotable: yes
        meta_attrs:
          - attrs:
              - name: notify
                value: true
    ha_cluster_constraints_colocation:
      - resource_leader:
          id: ag_cluster-clone
          role: Promoted
        resource_follower:
          id: virtualip
        options:
          - name: score
            value: INFINITY
    ha_cluster_constraints_order:
      - resource_first:
          id: ag_cluster-clone
          action: promote
        resource_then:
          id: virtualip
          action: start
  roles:
    - microsoft.sql.server
```

#### Configuring SQL Server with HA and Pacemaker on VMWare

If you want to configure Pacemaker from this role, you can set [mssql_manage_ha_cluster](#mssql_manage_ha_cluster) to `true` and provide variables required by the `fedora.linux_system_roles.ha_cluster` role to configure Pacemaker for your environment properly.
See the `fedora.linux_system_roles.ha_cluster` role documentation for more information.

Note that production environments require Pacemaker configured with fencing agents, this example playbook configures the `stonith:fence_vmware_soap` agent.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_ha_configure: true
    mssql_ha_ag_cluster_type: external
    mssql_ha_endpoint_port: 5022
    mssql_ha_cert_name: ExampleCert
    mssql_ha_master_key_password: "p@55w0rD1"
    mssql_ha_private_key_password: "p@55w0rD2"
    mssql_ha_reset_cert: false
    mssql_ha_endpoint_name: Example_Endpoint
    mssql_ha_ag_name: ExampleAG
    mssql_ha_db_names:
      - ExampleDB1
      - ExampleDB2
    mssql_ha_login: ExampleLogin
    mssql_ha_login_password: "p@55w0rD3"
    mssql_ha_virtual_ip: 192.XXX.XXX.XXX
    mssql_manage_ha_cluster: true
    ha_cluster_cluster_name: "{{ mssql_ha_ag_name }}"
    ha_cluster_hacluster_password: "p@55w0rD4"
    ha_cluster_cluster_properties:
      - attrs:
          - name: cluster-recheck-interval
            value: 2min
          - name: start-failure-is-fatal
            value: true
          - name: stonith-enabled
            value: true
    ha_cluster_resource_primitives:
      - id: vmfence
        agent: stonith:fence_vmware_soap
        instance_attrs:
          - attrs:
              - name: username
                value: vmware_Login
              - name: passwd
                value: vmware_password
              - name: ip
                value: vmware_ip
              - name: ssl_insecure
                value: 1
      - id: ag_cluster
        agent: ocf:mssql:ag
        instance_attrs:
          - attrs:
              - name: ag_name
                value: "{{ mssql_ha_ag_name }}"
        meta_attrs:
          - attrs:
              - name: failure-timeout
                value: 60s
      - id: virtualip
        agent: ocf:heartbeat:IPaddr2
        instance_attrs:
          - attrs:
              - name: ip
                value: "{{ mssql_ha_virtual_ip }}"
        operations:
          - action: monitor
            attrs:
              - name: interval
                value: 30s
    ha_cluster_resource_clones:
      - resource_id: ag_cluster
        promotable: yes
        meta_attrs:
          - attrs:
              - name: notify
                value: true
    ha_cluster_constraints_colocation:
      - resource_leader:
          id: ag_cluster-clone
          role: Promoted
        resource_follower:
          id: virtualip
        options:
          - name: score
            value: INFINITY
    ha_cluster_constraints_order:
      - resource_first:
          id: ag_cluster-clone
          action: promote
        resource_then:
          id: virtualip
          action: start
  roles:
    - microsoft.sql.server
```

#### Configuring SQL Server with HA and Pacemaker on Azure

If you want to configure Pacemaker from this role, you can set [mssql_manage_ha_cluster](#mssql_manage_ha_cluster) to `true` and provide variables required by the `fedora.linux_system_roles.ha_cluster` role to configure Pacemaker for your environment properly.
See the `fedora.linux_system_roles.ha_cluster` role documentation for more information.

#### HA and Pacemaker on Azure Prerequisites

* You must configure all required resources in Azure.
  For more information, see the following articles in Microsoft documentation:

  * [Setting up Pacemaker on Red Hat Enterprise Linux in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-rhel-pacemaker#1-create-the-stonith-devices)
  * [Tutorial: Configure availability groups for SQL Server on RHEL virtual machines in Azure](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/linux/rhel-high-availability-stonith-tutorial?view=azuresql)

Note that production environments require Pacemaker configured with fencing agents, this example playbook configures the `stonith:fence_azure_arm` agent.

This example playbooks sets the `firewall` variables for the `fedora.linux_system_roles.firewall` role and then runs this role to open the probe port configured in Azure.

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2019
    mssql_manage_firewall: true
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_ha_configure: true
    mssql_ha_ag_cluster_type: external
    mssql_ha_endpoint_port: 5022
    mssql_ha_cert_name: ExampleCert
    mssql_ha_master_key_password: "p@55w0rD1"
    mssql_ha_private_key_password: "p@55w0rD2"
    mssql_ha_reset_cert: false
    mssql_ha_endpoint_name: Example_Endpoint
    mssql_ha_ag_name: ExampleAG
    mssql_ha_db_names:
      - ExampleDB1
      - ExampleDB2
    mssql_ha_login: ExampleLogin
    mssql_ha_login_password: "p@55w0rD3"
    # Set mssql_ha_virtual_ip to the frontend IP address configured in the Azure
    # load balancer
    mssql_ha_virtual_ip: 192.XXX.XXX.XXX
    mssql_manage_ha_cluster: true
    ha_cluster_cluster_name: "{{ mssql_ha_ag_name }}"
    ha_cluster_hacluster_password: "p@55w0rD4"
    ha_cluster_extra_packages:
      - fence-agents-azure-arm
    ha_cluster_cluster_properties:
      - attrs:
          - name: cluster-recheck-interval
            value: 2min
          - name: start-failure-is-fatal
            value: true
          - name: stonith-enabled
            value: true
          - name: stonith-timeout
            value: 900
    ha_cluster_resource_primitives:
      - id: rsc_st_azure
        agent: stonith:fence_azure_arm
        instance_attrs:
          - attrs:
              - name: login
                value: ApplicationID
              - name: passwd
                value: servicePrincipalPassword
              - name: resourceGroup
                value: resourceGroupName
              - name: tenantId
                value: tenantID
              - name: subscriptionId
                value: subscriptionID
              - name: power_timeout
                value: 240
              - name: pcmk_reboot_timeout
                value: 900
      - id: azure_load_balancer
        agent: azure-lb
        instance_attrs:
          - attrs:
            # probe port configured in Azure
            - name: port
              value: 59999
      - id: ag_cluster
        agent: ocf:mssql:ag
        instance_attrs:
          - attrs:
            - name: ag_name
              value: "{{ mssql_ha_ag_name }}"
        meta_attrs:
          - attrs:
            - name: failure-timeout
              value: 60s
      - id: virtualip
        agent: ocf:heartbeat:IPaddr2
        instance_attrs:
          - attrs:
            - name: ip
              value: "{{ mssql_ha_virtual_ip }}"
        operations:
          - action: monitor
            attrs:
              - name: interval
                value: 30s
    ha_cluster_resource_groups:
      - id: virtualip_group
        resource_ids:
          - azure_load_balancer
          - virtualip
    ha_cluster_resource_clones:
      - resource_id: ag_cluster
        promotable: yes
        meta_attrs:
          - attrs:
            - name: notify
              value: true
    ha_cluster_constraints_colocation:
      - resource_leader:
          id: ag_cluster-clone
          role: Promoted
        resource_follower:
          id: azure_load_balancer
        options:
          - name: score
            value: INFINITY
    ha_cluster_constraints_order:
      - resource_first:
          id: ag_cluster-clone
          action: promote
        resource_then:
          id: azure_load_balancer
          action: start
    # Variables to open the probe port configured in Azure in firewall
    firewall:
      - port: 59999/tcp
        state: enabled
        permanent: true
        runtime: true
  roles:
    - fedora.linux_system_roles.firewall
    - microsoft.sql.server
```

## Configuring SQL Server to authenticate with Active Directory (AD) Server

Optional: Use variables starting with the `mssql_ad_` prefix to configure SQL Server to authenticate with Microsoft AD Server.

Note that creating users in Active Directory is not idempotent - it always return changed status.
This is because the `adutil` tool is not able to return statuses of users, hence the role must force-configure users.

### AD Considerations

This role uses the `fedora.linux_system_roles.ad_integration` role to join SQL Server with AD server.

To join to AD server, you must also provide the following variables for the `ad_integration` role:

* `ad_integration_realm` - to optionally join to the AD and create a keytab file
* `ad_integration_user` - to optionally join to the AD and obtain Kerberos ticket if [mssql_ad_kerberos_user](#mssql_ad_kerberos_user) is not provided
* `ad_integration_password` - to authenticate `ad_integration_user`
* Optional, You can configure DNS using ad_integration role by providing the following variables:

  ```yaml
  ad_integration_manage_dns: true
  ad_integration_dns_server: <AD_server_IP>
  ad_integration_dns_connection_name: <linux_network_interface>
  ad_integration_dns_connection_type: ethernet
  ```

* Optional: You can provide further variables for the `fedora.linux_system_roles.ad_integration` role if you need.

Optional: If you have already joined managed nodes to AD and you want to skip running the ad_integration role, you can set the [mssql_ad_join](#mssql_ad_join) variable to false.

### AD Prerequisites

Ensure that your AD Server and Linux host meet the prerequisites for joining.
For more information, see [Join SQL Server on a Linux host to an Active Directory domain](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-active-directory-join-domain?view=sql-server-ver15#prerequisites) and [Troubleshoot Active Directory authentication for SQL Server on Linux and containers](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-ad-auth-troubleshooting?view=sql-server-ver15) in Microsoft documentation.

### Finishing AD Server Configuration

* You must create Active Directory-based logins in Transact-SQL as described in [Create Active Directory-based SQL Server logins in Transact-SQL](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-ad-auth-adutil-tutorial?view=sql-server-ver16#create-active-directory-based-sql-server-logins-in-transact-sql) in *Tutorial: Use adutil to configure Active Directory authentication with SQL Server on Linux* in Microsoft documentation.
  You can write a T-SQL script and input it as described in [mssql_post_input_sql_file](#inputting-sql-scripts-to-sql-server). See example playbooks for how to create logins using the `mssql_post_input_sql_content` variable.

### Verifying Authentication

After you execute the role to configure AD Server authentication and complete [Finishing AD Server Configuration](#finishing-ad-server-configuration), you can log in using Azure Data Studio or complete the following procedure to verify that you can log in to SQL Server from your Linux machine using the `<sqluser>` account.

1. SSH into the `*<sqluser>@<domain.com>*` user on your Linux *client.domain.com* machine:

    ```bash
    ssh -l <sqluser>@<domain.com> <client.domain.com>
    ```

2. Obtain Kerberos ticket for the Administrator user:

    ```bash
    kinit Administrator@<DOMAIN.COM>
    ```

3. Use `sqlcmd` to log in to SQL Server and, for example, run the query to get current user:

    ```bash
    /opt/mssql-tools/bin/sqlcmd -S. -Q 'SELECT SYSTEM_USER'
    ```

### AD Variables

#### mssql_ad_configure

Set this variable to `true` to configure for AD Server authentication.
Setting to `false` does not remove configuration for AD Server authentication.

For an example playbook, see [Configuring AD integration with a pre-created keytab file](#configuring-ad-integration-with-general-parameters).

Default: `false`

Type: `bool`

#### mssql_ad_join

Optional: If you have already joined managed nodes to AD and you want to skip running the ad_integration role, you can set this variable to `false`.

For an example playbook, see [Configuring AD integration with a pre-created keytab file](#configuring-ad-integration-without-joining-to-ad).

If you define the `ad_integration_user` variable, the role obtains the kerberos ticket for creating keytab for the `ad_integration_user@ad_integration_realm` user with the `ad_integration_password` password.
If you don't define the `ad_integration_user` variable, the role obtains the kerberos ticket for `mssql_ad_sql_user@ad_integration_realm` user with the `mssql_ad_sql_password` password.

Default: `true`

Type: `bool`

#### mssql_ad_kerberos_user

Optional, you can use a specific user for obtaining kerberos ticket for creating the `mssql_ad_sql_user` user and keytab.

By default, the role uses the following logic:

1. If you define the `ad_integration_user` variable, the role obtains the kerberos ticket for the `ad_integration_user@ad_integration_realm` user with the `ad_integration_password` password.

2. If you don't define the `ad_integration_user` variable, the role obtains the kerberos ticket for `mssql_ad_sql_user@ad_integration_realm` user with the `mssql_ad_sql_password` password.

Default:

```yaml
mssql_ad_kerberos_user: >-
  {{ ad_integration_user if ad_integration_user is defined
  else mssql_ad_sql_user }}
```

Type: `string`

#### mssql_ad_kerberos_password

Optional, the password to use for obtaining kerberos ticket for the `mssql_ad_kerberos_user` user.

Default:

```yaml
mssql_ad_kerberos_password: >-
  {{ ad_integration_password if ad_integration_user is defined
  else mssql_ad_sql_password }}
```

Type: `string`

#### mssql_ad_keytab_file

Optional: You can use this variable if you don't want the role to generate a keytab file and instead want to pass a pre-created keytab file to mssql-server.

A keytab file must be pre-created on AD Server as per [Tutorial: Use Active Directory authentication with SQL Server on Linux](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-active-directory-authentication?view=sql-server-ver16). You must ensure that the keytab file is created for the managed node's hostname and for the user provided with the `mssql_ad_sql_user` variable.

For an example playbook, see [Configuring AD integration with a pre-created keytab file](#configuring-ad-integration-with-a-pre-created-keytab-file).

Default: `null`

Type: `string`

#### mssql_ad_keytab_remote_src

Optional: Only applicable when using [mssql_ad_keytab_file](#mssql_ad_keytab_file).

Influence whether the `mssql_ad_keytab_file` file needs to be transferred or already is present remotely.

If `false`, the role searches for the `mssql_ad_keytab_file` file on the controller node.

If `true`, the role searches for the `mssql_ad_keytab_file` file on managed nodes.

Default: `false`

Type: `bool`

#### mssql_ad_sql_user

User to be created in SQL Server and used for authentication.
The role configures this user with `Kerberos AES 128 bit encryption` and `Kerberos AES 256 bit encryption` enabled.

Default: `null`

Type: `string`

#### mssql_ad_sql_password

Password to be set for the [mssql_ad_sql_user](#mssql_ad_sql_user) user.

This variable is not required when using [mssql_ad_keytab_file](#mssql_ad_keytab_file).

Default: `null`

Type: `string`

#### mssql_ad_sql_user_dn

Optional: You must set `mssql_ad_sql_user_dn` if your AD server stores user account in a custom OU rather than in the `Users` OU.

AD distinguished name to create the [mssql_ad_sql_user](#mssql_ad_sql_user) at.

By default, the role builds `mssql_ad_sql_user_dn` the following way:

1. `CN={{ mssql_ad_sql_user }},` - name of the user created in AD
2. `CN=Users,` - the `Users` OU where AD stores users by default
3. `DC=<subdomain1>,DC=<subdomain2>,DC=<subdomainN>,` - all subdomain portions of the AD domain name provided with the `ad_integration_realm` variable
4. `DC=<TLD>` - top level domain

For example: `CN=sqluser,CN=Users,DC=DOMAIN,DC=COM`.

Default:

```yaml
mssql_ad_sql_user_dn: >-
  CN={{ mssql_ad_sql_user }},
  CN=Users,
  {{ ad_integration_realm.split(".")
  | map("regex_replace","^","DC=")
  | join(",") }}
```

Type: `string`

### AD Example Playbooks

#### Configuring AD integration with general parameters

```yaml
- name: Configure with AD server authentication
  hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2022
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_ad_configure: true
    mssql_ad_sql_user: sqluser
    mssql_ad_sql_password: "p@55w0rD1"
    ad_integration_realm: domain.com
    ad_integration_user: Administrator
    ad_integration_password: Secret123
    ad_integration_manage_dns: true
    ad_integration_dns_server: 1.1.1.1
    ad_integration_dns_connection_name: eth0
    ad_integration_dns_connection_type: ethernet
    mssql_post_input_sql_content: |-
      USE master;
      IF NOT EXISTS (
        SELECT name FROM sys.server_principals
        WHERE name = '<mydomain>\<myADlogin>'
      )
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login does not exist, creating';
        CREATE LOGIN [<mydomain>\<myADlogin>] FROM WINDOWS;
        PRINT 'The <mydomain>\<myADlogin> login created successfully';
      END
      ELSE
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login already exists, skipping'
      END
```

#### Configuring AD integration with a pre-created keytab file

If you received a pre-created keytab file and want the role to use it, set variables like in this example:

```yaml
- name: Configure with AD server authentication with a pre-created keytab file
  hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2022
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_ad_configure: true
    mssql_ad_keytab_file: /path/to/file
    mssql_ad_keytab_remote_src: false
    mssql_ad_sql_user: sqluser
    ad_integration_realm: domain.com
    ad_integration_user: Administrator
    ad_integration_manage_dns: true
    ad_integration_dns_server: 1.1.1.1
    ad_integration_dns_connection_name: eth0
    ad_integration_dns_connection_type: ethernet
    mssql_post_input_sql_content: |-
      USE master;
      IF NOT EXISTS (
        SELECT name FROM sys.server_principals
        WHERE name = '<mydomain>\<myADlogin>'
      )
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login does not exist, creating';
        CREATE LOGIN [<mydomain>\<myADlogin>] FROM WINDOWS;
        PRINT 'The <mydomain>\<myADlogin> login created successfully';
      END
      ELSE
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login already exists, skipping'
      END
```

#### Configuring AD integration without joining to AD

You must join managed host to AD Server yourself prior to running this playbook.

```yaml
- name: Configure with AD server authentication without joining to AD
  hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_standard_eula: true
    mssql_version: 2022
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_manage_firewall: true
    mssql_ad_configure: true
    mssql_ad_join: false
    mssql_ad_sql_user: sqluser
    mssql_ad_kerberos_user: user_administrator
    mssql_ad_kerberos_password: Secret123
    ad_integration_realm: domain.com
    mssql_post_input_sql_content: |-
      USE master;
      IF NOT EXISTS (
        SELECT name FROM sys.server_principals
        WHERE name = '<mydomain>\<myADlogin>'
      )
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login does not exist, creating';
        CREATE LOGIN [<mydomain>\<myADlogin>] FROM WINDOWS;
        PRINT 'The <mydomain>\<myADlogin> login created successfully';
      END
      ELSE
      BEGIN
        PRINT 'A <mydomain>\<myADlogin> login already exists, skipping'
      END
```

## License

MIT
