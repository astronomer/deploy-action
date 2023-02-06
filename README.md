# Deploy to Astro
This GitHub action automates deploying code from your GitHub repository to a Deployment on [Astro](https://www.astronomer.io/product/), Astronomer's data orchestration platform and managed service for Apache Airflow.

You can use and configure this GitHub action to easily deploy Apache Airflow DAGs to an Airflow environment on Astro. Specifically, you can:

- Avoid manually running `astro deploy` with the Astro CLI every time you make a change to your Astro project.
- Automate deploying code to Astro when you merge changes to a certain branch in your repository.
- Incorporate unit tests for your DAGs as part of the deploy process.

This GitHub action runs as a step within a GitHub workflow file. When your CI/CD pipeline is triggered, this action:

- Checks out your GitHub repository.
- Checks whether your commit only changed DAG code.
- Optional. Tests DAG code with `pytest`. See [Run tests with pytest](https://docs.astronomer.io/astro/test-and-troubleshoot-locally#run-tests-with-pytest).
- Runs `astro deploy --dags` if the commit only includes DAG code changes.
- Runs `astro deploy` if the commit includes project configuration changes.

## Prerequisites

To use this GitHub action, you need:

- An Astro project. See [Create a project](https://docs.astronomer.io/astro/create-project).
- A Deployment on Astro. See [Create a Deployment](https://docs.astronomer.io/astro/create-deployment).
- A Deployment API key ID and secret. See [Deployment API keys](https://docs.astronomer.io/astro/api-keys).

Astronomer recommends using [GitHub Actions secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) to store `ASTRONOMER_KEY_ID` and `ASTRONOMER_KEY_SECRET`. See the example in [Workflow file examples](https://github.com/astronomer/deploy-action#workflow-file-examples). 

## Use this action

To use this action, read [Automate code deploys with CI/CD](https://docs.astronomer.io/astro/ci-cd?tab=multiple%20branch#github-actions-dag-based-deploy). You will:

1. Create a GitHub Actions workflow in your repository that uses the latest version of this action. For example, `astronomer/deploy-action@v0.1`.
2. Configure the GitHub action to fit your team's use case. This could include disabling DAG-only deploys or adding tests. See below for options.
3. Make changes to your Astro project files in GitHub and let this action take care of deploying your code to Astro.

Astronomer recommends setting up multiple environments on Astro. See the [Multiple branch GitHub Action](https://docs.astronomer.io/astro/ci-cd?tab=multibranch#github-actions-image-only-deploys).

This action can only be used to deploy code to Astro Deployments. This README includes examples of how you can use the action to deploy code when changes are made to a main branch. To configure a CI/CD pipeline for multiple branches, see [Astronomer documentation](https://docs.astronomer.io/astro/ci-cd?tab=multiple%20branch#github-actions-dag-based-deploy). 

You can use the Deploy Action with DAG-only deploys activated or deactivated. When DAG-only deploys are activated, the action does not rebuild and deploy your image when your commit only includes changes to the `/dags` folder. For more information about DAG-only deploys, see [Deploy DAGs only](https://docs.astronomer.io/astro/deploy-code#deploy-dags-only).

The action completes the following steps whenever your CI/CD pipeline is triggered:

- Checks out your repository.
- Checks whether your commit only changed DAG code.
- Optional. Tests DAG code with pytest.
- If the commit included only changes to DAG code, pushes the change to Astro without building a new project image.
- If the change included changes to project configurations, rebuilds your project image and deploys it to Astro.

## Usage

To use the action, you must set the `ASTRONOMER_KEY_ID` and `ASTRONOMER_KEY_SECRET` environment variables in your GitHub Actions workflow to the Key ID and secret for an existing [Deployment API key](https://docs.astronomer.io/astro/api-keys). Astronomer recommends using GitHub Actions secrets to set these environment variables. An example workflow script is provided in **Workflow file examples**. 

## Configuration options

The following table lists the optional configuration options for Deploy Actions.

| Name | Default | Description |
| ---|---|--- |
| `dag-deploy-enabled` | `false` | When set to `true`, DAG files are deployed only when the DAG files are changed. Only set this to `true` when DAG-only deploys are activated on the Deployment you are deploying to. |
| `root-folder` | `.` | Specifies the path to to Astro project folder containing the 'dags' folder | 
| `parse` | `false` | When set to `true`, DAGs are parsed for errors before deployment |
| `pytest` | `false` | When set to `true`, pytests are run before deployment |
| `pytest-file` | (all tests run) | Specifies the custom pytest files to run with the pytest command. For example, you could specify `/tests/test-tags.py`|
| `force` | `false` | When set to `true`, your code is force deployed without testing or parsing |
| `image-name` |  | Specifies a custom, locally built image to deploy |


## Workflow file examples


In the following example, DAG-only deploys are enabled and DAG files are parsed for both image and DAG deploys. This workflow example deploys code when it is pushed into the main branch.

```
name: Astronomer CI - Deploy code

on:
  push:
    branches:
      - main

env:
  ## Sets Deployment API key credentials as environment variables
  ASTRONOMER_KEY_ID: ${{ secrets.ASTRONOMER_KEY_ID }}
  ASTRONOMER_KEY_SECRET: ${{ secrets.ASTRONOMER_KEY_SECRET }}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to Astro
      uses: astronomer/deploy-action@v0.1
      with:
        dag-deploy-enabled: true
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
    dag-folder: /example-dags/dags/
```

### Run Pytests

In the following example, the pytest located at `/tests/test-tags.py` runs before the image is deployed. 

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    pytest: true
    pytest-file: /tests/test-tags.py
```

### Ignore parsing and testing

In the following example, the parse and pytests are skipped.

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    force: true
```

### Use a custom image

In the following example, a custom image is built and deployed to an Astro Deployment.

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
      ASTRONOMER_KEY_ID: ${{ secrets.ASTRO_ACCESS_KEY_ID_DEV }}
      ASTRONOMER_KEY_SECRET: ${{ secrets.ASTRO_SECRET_ACCESS_KEY_DEV }}
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
        image-name: ${{ steps.image_tag.outputs.image_tag }}
      
```
