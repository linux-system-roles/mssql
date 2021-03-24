# mssql

![CI Testing](https://github.com/linux-system-roles/template/workflows/tox/badge.svg)

This role installs, configures, and starts Microsoft SQL Server (MSSQL).

The role also optimizes the operating system to improve performance and
throughput for MSSQL by applying the `mssql` Tuned profile.

The role currently uses MSSQL version 2019 only.

## Requirements

* MSSQL requires a machine with at least 2000 megabytes of memory.
* You must configure the firewall to enable connections on the MSSQL TCP port that
  you set with the `mssql_tcp_port` variable. The default port is 1443.
* Optional: If you want to input SQL statements and stored procedures to MSSQL,
  you must create a file with the `.sql` extension containing these SQL
  statements and procedures.

## Role Variables

### `mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula`

Set this variable to `true` to indicate that you accept EULA for installing the
`msodbcsql17` package.

The license terms for this product can be downloaded
from <https://aka.ms/odbc17eula> and found in `/usr/share/doc/msodbcsql17/LICENSE.txt`.

Default: `false`

### `mssql_accept_microsoft_cli_utilities_for_sql_server_eula`

Set this variable to `true` to indicate that you accept EULA for installing the
`mssql-tools` package.

The license terms for this product can be downloaded
from <http://go.microsoft.com/fwlink/?LinkId=746949> and found in
`/usr/share/doc/mssql-tools/LICENSE.txt`.

Default: `false`

### `mssql_accept_microsoft_sql_server_2019_standard_eula`

Set this variable to `true` to indicate that you accept EULA for using the
`mssql-conf` utility.

The license terms for this product can be found in `/usr/share/doc/mssql-server`
or downloaded from <https://go.microsoft.com/fwlink/?LinkId=2104078&clcid=0x409>.
The privacy statement can be viewed at
<https://go.microsoft.com/fwlink/?LinkId=853010&clcid=0x409>.

Default: `false`

### `mssql_password`

The password for the database sa user. The password must have a minimum length
of 8 characters, include uppercase and lowercase letters, base 10 digits or
non-alphanumeric symbols. Do not use single quotes ('), double quotes ("), and
spaces in the password because `sqlcmd` cannot authorize when the password
includes those symbols.

This variable is required when you run the role to install MSSQL.

When running this role on a host that has MSSQL set up, the mssql_password
variable overwrites the existing sa user password to the one that you specified.

Default: `null`

### `mssql_edition`

The edition of MSSQL to install.

This variable is required when you run the role to install MSSQL.

Use one of the following values:

* `Enterprise`
* `Standard`
* `Web`
* `Developer`
* `Express`
* `Evaluation`
* A product key in the form `#####-#####-#####-#####-#####`, where `#` is a
  number or a letter.
  For more information, see
  <https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-ver15>.

Default: `null`

### `mssql_tcp_port`

The port that MSSQL listens on.

If you define this variable, the role configures MSSQL with the defined TCP
port.

If you do not define this variable when setting up MSSQL, the role sets up MSSQL
to listen on the MSSQL default TCP port `1443`.

If you do not define this variable when configuring running MSSQL, the role does
not change the TCP port setting on MSSQL.

Default: `null`

### `mssql_ip_address`

The IP address that MSSQL listens on.

If you define this variable, the role configures MSSQL with the defined IP
address.

If you do not define this variable when setting up MSSQL, the role sets up MSSQL
to listen on the MSSQL default IP address `0.0.0.0`.

If you do not define this variable when configuring running MSSQL, the role does
not change the IP address setting on MSSQL.

Default: `null`

### `mssql_input_sql_file`

You can use the role to input a file containing SQL statements or procedures into
MSSQL. With this variable, enter the path to the SQL file containing the
database configuration.

When specifying this variable, you must also specify the `mssql_password`
variable because authentication is required to input an SQL file to MSSQL.

If you do not pass this variable, the role only configures the MSSQL Server
and does not input any SQL file.

Note that this task is not idempotent, the role always inputs an SQL file if
this variable is defined.

You can find an example of the SQL file at `tests/sql_script.sql`.

Default: `null`

## Example Playbook

```yaml
- hosts: all
  vars:
    mssql_accept_microsoft_odbc_driver_17_for_sql_server_eula: true
    mssql_accept_microsoft_cli_utilities_for_sql_server_eula: true
    mssql_accept_microsoft_sql_server_2019_standard_eula: true
    mssql_password: "p@55w0rD"
    mssql_edition: Evaluation
    mssql_tcp_port: 1433
    mssql_ip_address: 0.0.0.0
    mssql_input_sql_file: mydatabase.sql
  roles:
    - linux-system-roles.mssql
```

## License

MIT
