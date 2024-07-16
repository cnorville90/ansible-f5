# Exercise 1.0: Exploring the lab environment
======
Before you get started, please join us on slack! [Click here to join the
ansiblenetwork
slack](https://join.slack.com/t/ansiblenetwork/shared_invite/zt-3zeqmhhx-zuID9uJqbbpZ2KdVeTwvzw).
This will allow you to chat with other network automation engineers and
get help after the workshops concludes.

## Objective

Explore and understand the lab environment.

These first few lab exercises will be exploring the command-line
utilities of the Ansible Automation Platform. This includes

> -   [ansible-navigator](https://github.com/ansible/ansible-navigator)
>
>     - a command line utility and text-based user interface (TUI) for
>     running and developing Ansible automation content.
>
> -   [ansible-core](https://docs.ansible.com/core.html) - the base
>     executable that provides the framework, language and functions
>     that underpin the Ansible Automation Platform. It also includes
>     various cli tools like `ansible`, `ansible-playbook` and
>     `ansible-doc`. Ansible Core acts as the bridge between the
>     upstream community with the free and open source Ansible and
>     connects it to the downstream enterprise automation offering from
>     Red Hat, the Ansible Automation Platform.
>
> -   [Execution
>     Environments](https://docs.ansible.com/automation-controller/latest/html/userguide/execution_environments.html)
>
>     - not specifically covered in this workshop because the built-in
>     Ansible Execution Environments already included all the Red Hat
>     supported collections which includes all the network collections
>     we use for this workshop. Execution Environments are container
>     images that can be utilized as Ansible execution.
>
> -   [ansible-builder](https://github.com/ansible/ansible-builder) -not
>     specifically covered in this workshop, `ansible-builder` is a
>     command line utility to automate the process of building Execution
>     Environments.

If you need more information on new Ansible Automation Platform
components bookmark this landing page <https://red.ht/AAP-20>

### Step 1 - Connecting via VS Code
======
>
> It is highly encouraged to use Visual Studio Code to complete the
> workshop exercises. Visual Studio Code provides:
>


 Direct SSH access is available as a backup, or if Visual Studio Code
 is not sufficient to the student.

 ## Step 2 - Using the Terminal
======

-   Open the terminal tab
-   Fro purposes on this section, you will work as the "rhel" user on the controller machine command line.

      ``` bash
    cd ~/f5-bd-ansible-labs/
    ```

    ``` bash
    pwd
    ```

    **The Output should look something like**

    ``` console
    [rhel@controller$ cd ~/f5-bd-ansible-labs/
    [rhel@controller f5-workshop]$ pwd
    /home/rhel/f5-bd-ansible-labs
    [rhel@controller f5-bd-ansible-labs]$
    ```


    ``` bash
    cd ~/f5-bd-ansible-labs/101-F5-Basics/
    ```

    ``` bash
    pwd
    ```

    **The Output should look something like**

    ``` console
    [rhel-user@ede... ~]$ ~/f5-bd-ansible-labs/101-F5-Basics/
    [rhel-user@ede... 101-F5-Basics]$ pwd
    /home/rhel-user/f5-bd-ansible-labs/101-F5-Basics
    [rhel-user@ede... 101-F5-Basics]$
    ```

    -   `~` - the tilde in this context is a shortcut for the home
        directory, i.e. `/home/rhel`
    -   `cd` - Linux command to change directory
    -   `pwd` - Linux command for print working directory. This will
        show the full path to the current working directory.

### Step 3 - Examining Execution Environments
======

-   Create the Temp Directory to ensure the Execution Environment Runs
    correctly

    > ``` bash
    > mkdir /tmp/f5
    > ```
    >
    > ![](/home/rhel/images/create_tmp.png)
    >
    >
    > ::: note
    > ::: title
    > Note
    > :::
    >
    > If the above isnt done first an error will occur when trying to
    > run the execution environment about the directory not existing.
    > :::

-   Run the `ansible-navigator` command with the `images` argument to
    look at execution environments configured on the control node:

    > ``` bash
    > ansible-navigator images
    > ```
    >
    > ![](../images/ansible_network/1-explore/images/navigator-images.png)
    >
    > > Note: The output you see might differ from the above output

-   This command gives you information about all currently installed
    Execution Environments or EEs for short. Investigate an EE by
    pressing the corresponding number.

    > ![](../images/ansible_network/1-explore/images/navigator-ee-menu.png)

-   Selecting `2` for `Ansible version and collections` will show us all
    Ansible Collections installed on that particular EE, and the version
    of `ansible-core`:

    > ![](../images/ansible_network/1-explore/images/navigator-ee-collections.png)

-   When completed keep pressing `ESC` many times or type `:quit` to
    quit out of the ansible-navigator menus

### Step 4 - Examining the ansible-navigator configuration
======

-   Either use Visual Studio Code to open or use the `cat` command to
    view the contents of the `ansible-navigator.yml` file. The file is
    located in the home directory:

    > ``` bash
    > cat ~/.ansible-navigator.yml
    > ```
    >
    > **Output should look something like**
    >
    > ``` console
    > ---
    > ansible-navigator:
    > ansible:
    >    inventory:
    >       entries:
    >       - /home/rhel-user/lab_inventory/hosts
    > execution-environment:
    >    container-engine: podman
    >    enabled: true
    >    #image: quay.io/acme_corp/f5_ee:latest
    >    image: quay.io/f5_business_development/mmabis-ee-test:latest
    >    pull:
    >       policy: missing
    >    volume-mounts:
    >    - dest: /etc/ansible/
    >       src: /etc/ansible/
    >    - dest: /tmp/f5/
    >       src: /tmp/f5/
    >    - dest: /usr/share/nginx/html/asm-profiles
    >       src: /usr/share/nginx/html/asm-profiles
    > ```