"""
DAG served from a non-default path, for the named DAG bundle e2e test.

The test deploys this directory with `dags-path: teams/a/dags` and
`dag-bundle-name`, so it exercises both the custom DAGs path and the named
bundle. It is deliberately trivial: it only has to parse and be uploaded.
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
