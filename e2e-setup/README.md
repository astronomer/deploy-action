# End-to-End Setup

This folder contains the necessary setup for running end-to-end tests for the Astro Deploy Action. Below is the folder structure and a brief description of the contents at the first level.

The E2E tests could be triggered automatically when a new commit is pushed to main, or it could be manually triggered. E2E setup also supports specifying custom Astro environment, organization id, workspace id or organization API token to run these tests when triggered manually from Actions page (if not specified the test setup will pick the default values set as secrets).

## Folder Structure

```
e2e-setup/
├── astro-project/
├── deployment-templates/
│   ├── deployment-hibernate.yaml
│   └── deployment.yaml
├── mocks/
│   ├── dag-deploy-git.sh
│   └── dbt-deploy-git.sh
├── dbt/
│   └── dbt_project.yml
```

### astro-project

Astro project folder contains a basic airflow project initialized via Astro CLI, which will deployed as part of tests via deploy action

### dbt

The dbt folder contains a basic sample dbt_project.yml file, which is used to define the configuration of a dbt project. This file includes settings such as the project name, version, and other configurations necessary for running dbt commands.

### deployment-templates

Deployment templates contains the basic templates used by e2e tests to create required deployments against which tests would be executed

- **deployment-hibernate.yaml**: Template for creating a deployment with forever hibernation schedules.
- **deployment.yaml**: Template for creating a standard deployment.

### mocks

mocks folder contain script or logic to mock different part of the logic during e2e tests execution.
As of now it only contain `git.sh` which would replace the git cli so that in deploy action we could mock that only dags file has changed during dag deploy tests.

- **git.sh**: Script to mock git commands for simulating DAGs-only deploy scenarios.
