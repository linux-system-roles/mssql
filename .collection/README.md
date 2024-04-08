# Microsoft SQL Ansible Collection

This collection contains a role for managing Microsoft SQL Server.

## Compatible OS

* Red Hat Enterprise Linux 7 (RHEL 7+)
* Red Hat Enterprise Linux 8 (RHEL 8+)
* Red Hat Enterprise Linux 9 (RHEL 9+)
* Fedora
* RHEL derivatives such as CentOS
* Suse Linux Enterprise Server 15 (SLES 15)
* OpenSUSE 15

## Installing the collection

There are currently two ways to install this collection, using `ansible-galaxy` or RPM package.

### Installing with ansible-galaxy

You can install the collection with `ansible-galaxy` by entering the following command:

```bash
ansible-galaxy collection install microsoft.sql
```

For more information, see [Using Ansible collections](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html) in the *Ansible* documentation.

After the installation, you can call the server role from playbooks with `microsoft.sql.server`.

When installing using `ansible-galaxy`, by default, you can find the role documentation at `~/.ansible/collections/ansible_collections/microsoft/sql/roles/server/README.md`.
If you store collections in a custom directory, you can find where `ansible-galaxy` installed the collection by running `ansible-galaxy collection list microsoft.sql`.

### Installing using RPM package

You can install the collection with the software package management tool `dnf` by running the following command:

```bash
dnf install ansible-collection-microsoft-sql
```

When installing using `dnf`, you can find the role documentation in markdown format at `/usr/share/doc/ansible-collection-microsoft-sql/microsoft.sql-server/README.md` and in HTML format at `/usr/share/doc/ansible-collection-microsoft-sql/microsoft.sql-server/README.html`.

## Supported Ansible Versions

The supported Ansible versions are aligned with currently maintained Ansible versions that support Collections - Ansible 2.9 and later.
For the list of maintained Ansible versions, see [Releases and maintenance](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#release-status) in the *Ansible* documentation.
