# Astronomer Actions
Custom Github Actions to create CI/CD pipelines for Astro. See [Astornomer's CI/CD documentation](https://docs.astronomer.io/astro/ci-cd) page for more information on creating CI/CD pipelines to deploy code to Astro Deployments.

This repo contains the following Custom Github Actions:
- Deploy

## Deploy Action

Deploys your Astro project to an Astro Cloud Deployment during a CI/CD workflow. This action should be used with a github ations workflow that runs when code is merged into a "main"(or equivalent) branch. Works with DAG-Only Deploys enabled or disabled. Enabling Dag-Only Deploys will skip an image deploy if only files in `/dags` folder change. More information can be found in Astronomer's ][DAG-only Deploys documentation](https://docs.astronomer.io/astro/deploy-code#deploy-dags-only[]).

This action will execute the following steps if DAG:
1. Checkout your current repo
2. Determine if only DAG code changed
2. Build your Astro Project into an image if files outside the `/dags` folder changed
3. Parse or Pytest your DAG code (optional)
4. Push your image to Astro's image Registry if files outside the `/dags` folder changed
5. Deploy your image to your Astro Deployment if files outside the `/dags` folder changed
6. Deploy only your `dags/` folder to your Astronomer Deployment if only files inside the `/dags` folder changed

### Usage

The Deploy Action is designed to be used with https://docs.astronomer.io/astro/api-keys