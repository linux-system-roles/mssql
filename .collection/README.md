# Microsoft SQL Ansible Collection

## Description

This collection contains a role for managing Microsoft SQL Server.

## Installation

There are currently two ways to install this collection, using `ansible-galaxy` or RPM package.

### Installing with ansible-galaxy

You can install the collection with `ansible-galaxy` by entering the following command:

```shell
ansible-galaxy collection install microsoft.sql
```

You can also include it in a requirements.yml file and install it with ansible-galaxy collection install -r requirements.yml, using the format:

```yaml
collections:
  - name: microsoft.sql
```

Note that if you install any collections from Ansible Galaxy, they will not be upgraded automatically when you upgrade the Ansible package.
To upgrade the collection to the latest available version, run the following command:

```shell
ansible-galaxy collection install microsoft.sql --upgrade
```

You can also install a specific version of the collection, for example, if you need to downgrade when something is broken in the latest version (please report an issue in this repository). Use the following syntax to install version 1.0.0:

```shell
ansible-galaxy collection install microsoft.sql:==1.0.0
```

See [using Ansible collections](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html) for more details.

After the installation, you can call the server role from playbooks with `microsoft.sql.server`.
When installing using `ansible-galaxy`, by default, you can find the role documentation at `~/.ansible/collections/ansible_collections/microsoft/sql/roles/server/README.md`.

### Installing using RPM package

You can install the collection with the software package management tool `dnf` by running the following command:

```bash
dnf install ansible-collection-microsoft-sql
```

When installing using `dnf`, you can find the role documentation in markdown format at `/usr/share/doc/ansible-collection-microsoft-sql/microsoft.sql-server/README.md` and in HTML format at `/usr/share/doc/ansible-collection-microsoft-sql/microsoft.sql-server/README.html`.

## Use Cases

The common use cases are the following

* I want to install, configure, and manage SQL Server on one or more systems
* I want to configure several systems with Always On Availability Groups
* I want to configure SQL Server to authenticate with Active Directory Server

For more scenarios and examples, see role's documentation.

## Contributing (Optional)

If you wish to contribute to roles within this collection, feel free to open a pull request for the role's upstream repository at https://github.com/linux-system-roles/mssql.

We recommend that prior to submitting a PR, you familiarize yourself with our [Contribution Guidelines](https://linux-system-roles.github.io/contribute.html).

## Support

* Red Hat Enterprise Linux 7 (RHEL 7+)
* Red Hat Enterprise Linux 8 (RHEL 8+)
* Red Hat Enterprise Linux 9 (RHEL 9+)
* Fedora
* RHEL derivatives such as CentOS
* Suse Linux Enterprise Server 15 (SLES 15)
* OpenSUSE 15

## Release Notes and Roadmap

For the list of versions and their changelog, see CHANGELOG.md within this collection.

## Related Information

Where available, link to general how to use collections or other related documentation applicable to the technology/product this collection works with. Useful materials such as demos, case studies, etc. may be linked here as well.

## License Information

- MIT