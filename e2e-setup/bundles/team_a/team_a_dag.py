"""
DAG served from a non-default path, for the named DAG bundle e2e test.

The test deploys this directory with `dags-path` and `dag-bundle-name` from
the repository root, outside any Astro project, so it exercises the custom
DAGs path, the named bundle, and a DAG deploy that needs no project. It is
deliberately trivial: it only has to parse and be uploaded.
"""

from airflow.decorators import dag, task
from pendulum import datetime


@dag(
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["e2e", "team-a"],
)
def team_a_dag():
    @task
    def hello() -> str:
        return "hello from team a"

    hello()


team_a_dag()
