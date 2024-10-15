# AutoGPT Terraform and Packer Configuration

- [AutoGPT Terraform and Packer Configuration](#autogpt-terraform-and-packer-configuration)
  - [Overview](#overview)
  - [Devcontainers](#devcontainers)
  - [Auto-scaling Configuration](#auto-scaling-configuration)

## Overview

This repository consists of Terraform configuration to creation necessary AzureRM Virtual Machine resources for hosting AutoGPT. With the help of configuring the VM via Packer, AutoGPT is retrieved from GitHub and all necessary tools are installed to run AutoGPT successfully.

## Devcontainers

Devcontainers requires the VS Code, additional extensions, and Docker to run on your machine. Please consult with the [Getting Started](https://code.visualstudio.com/docs/devcontainers/containers) guide to learn more.

`runArgs` is looking for a `./devcontainer/.env` file with a `GITHUB_TOKEN` set. This is for local development only, please set this file with your `GITHUB_TOKEN` for enabling the script.

```json
// For format details, see https://aka.ms/devcontainer.json. For config options, see the
// README at: https://github.com/devcontainers/templates/tree/main/src/ubuntu
{
	"name": "Ubuntu: GitHub",
	// Or use a Dockerfile or Docker Compose file. More info: https://containers.dev/guide/dockerfile
	"image": "mcr.microsoft.com/devcontainers/base:jammy",
	"features": {
		"ghcr.io/devcontainers/features/python:1": {
			"installTools": true,
			"version": "latest"
		},
		"ghcr.io/devcontainers-contrib/features/black:2": {
			"version": "latest"
		},
		"ghcr.io/devcontainers-contrib/features/coverage-py:2": {
			"version": "latest"
		},
		"ghcr.io/devcontainers-contrib/features/mypy:2": {
			"version": "latest"
		},
		"ghcr.io/devcontainers-contrib/features/pylint:2": {
			"version": "latest"
		},
		"ghcr.io/devcontainers/features/github-cli:1": {
			"installDirectlyFromGitHubRelease": true,
			"version": "latest"
		}
	},
	"customizations": {
		"extensions": [
			"ms-python.python",
			"alexcvzz.vscode-sqlite",
			"donjayamanne.python-extension-pack",
			"ms-python.vscode-pylance",
			"ms-python.black-formatter",
			"littlefoxteam.vscode-python-test-adapter"
		],
	},
	"mounts": [
		"source=profile,target=/root,type=volume",
		"target=/root/.vscode-server,type=volume"
	],
	"remoteUser": "root",
	"runArgs": ["--env-file", ".devcontainer/.env"],

	// onstartcommand that installs lsd
	"postCreateCommand": "curl -L https://github.com/lsd-rs/lsd/releases/download/0.23.1/lsd_0.23.1_amd64.deb  -o lsd_0.23.1_amd64.deb && dpkg -i lsd_0.23.1_amd64.deb && rm lsd_0.23.1_amd64.deb",
	"postStartCommand": "cd /workspaces/${containerWorkspaceFolderBasename}/scripts/migration; pip install --root-user-action=ignore -r requirements.txt",

	// Use 'forwardPorts' to make a list of ports inside the container available locally.
	// "forwardPorts": [],
}
```

## Auto-scaling Configuration

This section provides information on how to configure and use auto-scaling for virtual machines using Azure VM Scale Sets.

### Configuration

The auto-scaling configuration is defined in the `infra/terraform/main.tf` file. The following variables are used for auto-scaling configuration:

- `vmss_capacity`: The initial capacity of the VM Scale Set.
- `vmss_min_capacity`: The minimum capacity of the VM Scale Set.
- `vmss_max_capacity`: The maximum capacity of the VM Scale Set.

### Usage

To use auto-scaling, follow these steps:

1. Update the `infra/terraform/variables.tf` file with the desired values for `vmss_capacity`, `vmss_min_capacity`, and `vmss_max_capacity`.
2. Run the `run.sh` script to apply the changes.

Example:

```sh
export TF_VAR_openai_api_key=your_openai_api_key
export TF_VAR_client_id=your_client_id
export TF_VAR_client_secret=your_client_secret
export TF_VAR_tenant_id=your_tenant_id
export TF_VAR_subscription_id=your_subscription_id

./run.sh
```
