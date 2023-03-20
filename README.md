# Deploy to Astro
This GitHub action automates deploying code from your GitHub repository to a Deployment on [Astro](https://www.astronomer.io/product/), Astronomer's data orchestration platform and managed service for Apache Airflow.

You can use and configure this GitHub action to easily deploy Apache Airflow DAGs to an Airflow environment on Astro. Specifically, you can:

- Avoid manually running `astro deploy` with the Astro CLI every time you make a change to your Astro project.
- Automate deploying code to Astro when you merge changes to a certain branch in your repository.
- Incorporate unit tests for your DAGs as part of the deploy process.
- Create/delete a Deployment Preview. A Deployment Preveiw is an Astro Deployment that mirrors the configuration of your orginal Deployment. 

This GitHub action runs as a step within a GitHub workflow file. When your CI/CD pipeline is triggered, this action:

- Checks out your GitHub repository.
- Optionaly create or delete a Deployment Preview to test your code changes on before deploying to production.
- Checks whether your commit only changed DAG code.
- Optional. Tests DAG code with `pytest`. See [Run tests with pytest](https://docs.astronomer.io/astro/test-and-troubleshoot-locally#run-tests-with-pytest).
- Runs `astro deploy --dags` if the commit only includes DAG code changes.
- Runs `astro deploy` if the commit includes project configuration changes.

## Prerequisites

To use this GitHub action, you need:

- An Astro project. See [Create a project](https://docs.astronomer.io/astro/create-project).
- A Deployment on Astro. See [Create a Deployment](https://docs.astronomer.io/astro/create-deployment).
- A Deployment API Token. See [API Tokens]()
- Or a Deployment API key ID and secret. See [Deployment API keys](https://docs.astronomer.io/astro/api-keys).

Astronomer recommends using [GitHub Actions secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) to store `ASTRO_API_TOKEN` or Deployment API Keys. See the example in [Workflow file examples](https://github.com/astronomer/deploy-action#workflow-file-examples). 

## Use this action

To use this action, read [Automate code deploys with CI/CD](https://docs.astronomer.io/astro/ci-cd?tab=multiple%20branch#github-actions-dag-based-deploy). You will:

1. Create a GitHub Actions workflow in your repository that uses the latest version of this action. For example, `astronomer/deploy-action@v0.1`.
2. Configure the workflow to fit your team's use case. This could include creating a deployment preview or adding tests. See [Configuration options](https://github.com/astronomer/deploy-action#configuration-options).
3. Make changes to your Astro project files in GitHub and let this GitHub Actions workflow take care of deploying your code to Astro.

Astronomer recommends setting up multiple environments on Astro. See the [Multiple branch GitHub Actions workflow](https://docs.astronomer.io/astro/ci-cd?tab=multibranch#github-actions-image-only-deploys) in Astronomer documentation.


## Configuration options

The following table lists the configuration options for the Deploy to Astro action.

| Name | Default | Description |
| ---|---|--- |
| `action` | `deploy` | Specify what action you would like to take. Use this option to create or delete deployment previews. Specify either `create-deployment-preview`, `delete-deployment-preview` or `deploy-deployment-preview`. Don't sepcify anything if you are deploying to a regular deployment |
| `deployment-id` | `false` | Specifies the id of the deployment you to make a preview from or are deploying too |
| `deployment-name` | `false` | Specifies The name of the deployment you want to make preview from or are deploying too. Cannot be used with `deployment-id` |
| `root-folder` | `.` | Specifies the path to the Astro project directory that contains the `dags` folder |
| `parse` | `false` | When set to `true`, DAGs are parsed for errors before deploying to Astro |
| `pytest` | `false` | When set to `true`, all pytests in the `tests` directory of your Astro project are run before deploying to Astro. See [Run tests with pytest](https://docs.astronomer.io/astro/test-and-troubleshoot-locally#run-tests-with-pytest) |
| `pytest-file` | (all tests run) | Specifies a custom pytest file to run with the pytest command. For example, you could specify `/tests/test-tags.py`|
| `force` | `false` | When set to `true`, your code is deployed and skips any pytest or parsing errors |
| `image-name` | | Specifies a custom, locally built image to deploy |
| `workspace` | `false` | If you are using an organization token you will need to provide a workspace-name or id |
| `preview-name` | `false` | Specifies custom preview name. By default this is branch name “_” deployment name |


## Workflow file examples


In the following example, the GitHub action deploys code to Astro. This example assumes that you have one Astro Deployment and one branch. When a change is merged to the `main` branch, your Astro project is deployed to Astro. DAG files are parsed on every deploy and no pytests are ran.

```
name: Astronomer CI - Deploy code

on:
  push:
    branches:
      - main

env:
  ## Set API Token as an environment variable
  ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to Astro
      uses: astronomer/deploy-action@v0.1
      with:
        deployment-id: <deployment id>
        parse: true
```

Use the following topics to further configure the action based on your needs.

### Change the DAG folder

In the following example, the folder `/example-dags/dags` is specified as the DAG folder.

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    deployment-id: <deployment id>
    dag-folder: /example-dags/dags/
```

### Run Pytests

In the following example, the pytest located at `/tests/test-tags.py` runs before deploying to Astro.

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    deployment-id: <deployment id>
    pytest: true
    pytest-file: /tests/test-tags.py
```

### Ignore parsing and testing

In the following example, `force` is enabled and both the DAG parse and pytest processes are skipped.

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    deployment-id: <deployment id>
    force: true
```

### Deploy a custom Docker image

In the following example, a custom Docker image is built and deployed to an Astro Deployment.

```
name: Astronomer CI - Additional build-time args

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      ## Set API Token as an environment variable
      ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN
    steps:
    - name: Check out the repo
      uses: actions/checkout@v3
    - name: Create image tag
      id: image_tag
      run: echo ::set-output name=image_tag::astro-$(date +%Y%m%d%H%M%S)
    - name: Build image
      uses: docker/build-push-action@v2
      with:
        tags: ${{ steps.image_tag.outputs.image_tag }}
        load: true
        # Define your custom image's build arguments, contexts, and connections here using
        # the available GitHub Action settings:
        # https://github.com/docker/build-push-action#customizing .
        # This example uses `build-args` , but your use case might require configuring
        # different values.
        build-args: |
          <your-build-arguments>
    - name: Deploy to Astro
      uses: astronomer/deploy-action@v0.1
      with:
        deployment-id: <deployment id>
        image-name: ${{ steps.image_tag.outputs.image_tag }}
      
```

## Deployment Preview Templates

This section contains four workflow files that you will need in your repository to have a full Deployment Preview Cycle running for your Deployment. A Deployment Preview is an Astro Deployment that mirrors the configuration of your original Deployment. This Deployment Preview can be used to test your new pipelines changes before pushing them to your orginal Deployment. The scripts below will take your pipeline changes through the following flow:

1. When a new branch is created a Deployment Preview will be created based off your orginal Deployment
2. When a PR is created from a branch code changes will be deployed to the Deployment Preivew
3. When a PR is merged into your "main" branch code changes will be deployed to the orginal Deployment
4. When a branch is deleted the the corresponding Deployment Preview will also be deleted

## Create Deployment Preivew

```
name: Astronomer CI - Create deployment preview

on:
  create:
    branches:
    - "**"

env:
  ## Sets Deployment API key credentials as environment variables
  ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Create Deployment Preivew
      uses: astronomer/deploy-action@v0.2
      with:
        action: create-deployment-preview
        deployment-id: <orginal deployment id>
```

## Deploy to Deployment Preview

```
name: Astronomer CI - Deploy code to Preview

on:
  pull_request:
    branches:
      - main

env:
  ## Sets Deployment API key credentials as environment variables
  ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to Deployment Preivew
      uses: astronomer/deploy-action@v0.2
      with:
        action: deploy-deployment-preview
        deployment-id: <orginal deployment id>
```

## Delete Deployment Preview

```
name: Astronomer CI - Delete Deployment Preview

on:
  delete:
    branches:
    - "**"

env:
  ## Sets Deployment API key credentials as environment variables
  ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Create Deployment Preivew
      uses: astronomer/deploy-action@v0.2
      with:
        action: delete-deployment-preview
        deployment-id: <orginal deployment id>
```

## Deploy to Orginal Deployment

```
name: Astronomer CI - Deploy code to Astro

on:
  push:
    branches:
      - main

env:
  ## Sets Deployment API key credentials as environment variables
  ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to Astro
      uses: astronomer/deploy-action@v0.2
      with:
        deployment-id: <orginal deployment id>
```
## Delete Deployment Preview

```
name: Astronomer CI - Delete Deployment Preview

on:
  delete:
    branches:
    - "**"

env:
  ## Sets Deployment API key credentials as environment variables
  ASTRO_API_TOKEN: ${{ secrets.ASTRO_API_TOKEN }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Create Deployment Preivew
      uses: astronomer/deploy-action@v0.2
      with:
        action: delete-deployment-preview
        deployment-id: <orginal deployment id>
```
