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
2. Configure the workflow to fit your team's use case. This could include disabling DAG-only deploys or adding tests. See [Configuration options](https://github.com/astronomer/deploy-action#configuration-options).
3. Make changes to your Astro project files in GitHub and let this GitHub Actions workflow take care of deploying your code to Astro.

Astronomer recommends setting up multiple environments on Astro. See the [Multiple branch GitHub Actions workflow](https://docs.astronomer.io/astro/ci-cd?tab=multibranch#github-actions-image-only-deploys) in Astronomer documentation.


## Configuration options

The following table lists the configuration options for the Deploy to Astro action.

| Name | Default | Description |
| ---|---|--- |
| `dag-deploy-enabled` | `false` | When set to `true`, this action includes conditional logic that deploys only DAG files to Astro when only the DAGs directory changes. Only set this to `true` when the DAG-only deploy feature is enabled on your Astro Deployment. See [Deploy DAGs only](https://docs.astronomer.io/astro/deploy-code#deploy-dags-only) |
| `root-folder` | `.` | Specifies the path to the Astro project directory that contains the `dags` folder | 
| `parse` | `false` | When set to `true`, DAGs are parsed for errors before deploying to Astro |
| `pytest` | `false` | When set to `true`, all pytests in the `tests` directory of your Astro project are run before deploying to Astro. See [Run tests with pytest](https://docs.astronomer.io/astro/test-and-troubleshoot-locally#run-tests-with-pytest) |
| `pytest-file` | (all tests run) | Specifies a custom pytest file to run with the pytest command. For example, you could specify `/tests/test-tags.py`|
| `force` | `false` | When set to `true`, your code is deployed and skips any pytest or parsing errors |
| `image-name` | <custom-Docker-image-name> | Specifies a custom, locally built image to deploy |


## Workflow file examples


In the following example, the GitHub action deploys code to Astro with DAG-only deploys enabled. This example assumes that you have one Astro Deployment and one branch. When a change is merged to the `main` branch, your Astro project is deployed to Astro. DAG files are parsed on every deploy and no pytests are ran.

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

In the following example, the pytest located at `/tests/test-tags.py` runs before deploying to Astro.

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
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
