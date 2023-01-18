# Deploy Action
You use Deploy Action to create CI/CD pipelines that automate the deployment of code changes to a Deployment. For more information about Astro CI/CD workflows, see [Automate code deploys with CI/CD](https://docs.astronomer.io/astro/ci-cd).

Deploy Action should only be used in a GitHub Actions workflow that runs when code is merged into a `main` or an equivalent branch. You can use the Deploy Action with DAG-only deploys activated or deactivated. When DAG-only deploys are activated, an image deploy is not completed when only the files in the `/dags` folder change. For more information about DAG-only deploys, see [Deploy DAGs only](https://docs.astronomer.io/astro/deploy-code#deploy-dags-only).

The following is the workflow for Deploy Action:
- Your current repository is checked out
- It is determined if only DAG code changed
- Your Astro project is built into an image when you change files outside the `/dags` folder
- Optional. Your DAG code is parsed or tested with Pytest
- Your image is pushed to the Astro image registry if you changed files outside the `/dags` folder
- Your image is deployed to your Deployment if you changed files outside the `/dags` folder
- Your `dags/` folder is deployed to your Deployment if you changed files inside the `/dags` folder

## Usage

Deploy Action is intended to be used with [Deployment API keys](https://docs.astronomer.io/astro/api-keys). To use Deploy Action, you need to set the `ASTRONOMER_KEY_ID` and `ASTRONOMER_KEY_SECRET` environment variables in your GitHub Actions workflow. Astronomer recommends using GitHub Actions secrets to set the environment variables. An example workflow script is provided in **Deploy code example**. 

## Configuration options

The following table lists the optional configuration options for Deploy Actions.

| Name | Default | Description |
| ---|---|--- |
| `dag-deploy-enabled` | `false` | When set to `true`, DAG files are deployed only when the DAG files are changed. Only set this to `true` when DAG-only deploys are activated on the Deployment you are deploying to. |
| `root-folder` | `.` | Specifies the path to to Astro project folder containing the 'dags' folder | 
| `parse` | `false` | When set to `true`, DAGs are parsed for errors before deployment |
| `pytest` | `false` | When set to `true`, pytests are run before deployment |
| `pytest-file` | (all tests run) | Specifies the custom pytest files to run with the pytest command. For example, you could specify `/tests/test-tags.py`
| `force` | `false` | When set to `true`, your code is force deployed without testing or parsing
| `image-name` |  | Specifies a custom, locally built image to deploy |


## Deploy code example

The following example shows how to use Deploy Action to deploy your code to an Astro Deployment whenever code is pushed to the main branch of your projects repository. The `ASTRONOMER_KEY_ID` and `ASTRONOMER_KEY_SECRET` environment variable values are defined by your [Deployment API key](https://docs.astronomer.io/astro/api-keys).

In the following example, DAG-only deploys are enabled and DAG files are parsed in both image and DAG deploys.

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
