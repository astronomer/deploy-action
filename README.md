# Astronomer Deploy Action
Custom Github Action to create CI/CD pipelines that deploys Airflow code to Astro Airflow Deployments during a CI/CD workflow. See [Astronomer's CI/CD documentation](https://docs.astronomer.io/astro/ci-cd) page for more information on creating CI/CD pipelines for Astro.

This action should be used with a Github Actions workflow that runs when code is merged into `main` (or equivalent) branch. Works with DAG-Only Deploys enabled or disabled. Enabling Dag-Only Deploys will skip an image deploy if only files in `/dags` folder change. More information can be found in Astronomer's [DAG-only Deploys documentation](https://docs.astronomer.io/astro/deploy-code#deploy-dags-only).

This action will execute the following steps:
1. Checkout your current repo
2. Determine if only DAG code changed
2. Build your Astro Project into an image if files outside the `/dags` folder changed
3. Parse or Pytest your DAG code (optional)
4. Push your image to Astro's image Registry if files outside the `/dags` folder changed
5. Deploy your image to your Astro Deployment if files outside the `/dags` folder changed
6. Deploy only your `dags/` folder to your Astronomer Deployment if only files inside the `/dags` folder changed

### Usage

The Deploy Action is designed to be used with [Deployment API keys](https://docs.astronomer.io/astro/api-keys). You must have your `ASTRONOMER_KEY_ID` and `ASTRONOMER_KEY_SECRET` set as environment variables in your Github Actions Workflow for this command to work. We recommend doing this through Github Actions secrets. For an example workflow script scroll down to the Examples section. The action uses these keys to login to Astro and determine what Deployment to deploy to. 

#### Inputs

You can configure the Deploy Actions behavior through a few options. None of the options are required.

| Name | Default | Description |
| ---|---|--- |
| `dag-deploy-enabled` | `false` | If true, only DAG files will be deployed when only DAG files are changed. __Only set this to true if DAG Deploys has been enabled for the Deployment you are deploying to__ |
| `root-folder` | `.` | Specify the path to to Astro project folder that contains that 'dags' folder | 
| `parse` | `false` | If true, DAGs will be parsed for errors before deployment |
| `pytest` | `false` | If true, pytests will run before deployment |
| `pytest-file` | (all tests run) | Specify custom pytest files to run with the pytest command. For example, you could specify `/tests/test-tags.py`
| `force` | `false` | If true, your code will be force deployed, which skips tests and DAG parsing
| `image-name` |  | Specify a custom locally built image to deploy |


### Example Workflow File

The following example shows how the Deploy Action can be uesd to deploy your code to an Astro Deployment whenever code is pushed to the main branch of your projects repository. The ASTRONOMER_KEY_ID and ASTRONOMER_KEY_SECRET values come from your [Deployment API key](https://docs.astronomer.io/astro/api-keys).

In this particular example DAG deploys are enabled are enabled and DAG files are being parsed in both image and DAG Deploys.

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
### Change DAG Folder Example

In the following example the folder `/example-dags/dags` is specified as the DAG folder.

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    dag-folder: /example-dags/dags/
```

### Example using Pytests

In the following example the pytest located at `/tests/test-tags.py` runs before the image is deployed. 

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    pytest: true
    pytest-file: /tests/test-tags.py
```

### Example using force

In the following example the parse and pytests are skipped because the `--force` flag is enabled.

```
steps:
- name: Deploy to Astro
  uses: astronomer/deploy-action@v0.1
  with:
    force: true
```

### Example using a custom iamge

In the following example custom image is built and deployed to an Astro Deployment using the `docker/build-push-action` and `astronomer/deploy-action`.

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
