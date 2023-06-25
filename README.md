# Things to do after installing Ubuntu

After installing or re-installing Ubuntu on your computer, there are a few essential tasks to ensure that your system is up and running optimally. Here's a helpful guide to follow, including an ansible script to automate these tasks and make the process more manageable.

## Supported versions

* 20.04 - Focal
* 22.04 - Jammy

## Pre-Execution Requirements

Before running the ansible script, you need to ensure that you have the following installed:

```
sudo apt -y update && apt -y install ansible git sshpass
```

## Executing the Ansible Script

```
ansible-playbook exec.yml -l localhost
```
