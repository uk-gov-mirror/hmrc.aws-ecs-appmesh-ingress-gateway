import uuid

from locust import HttpUser, task, between


class QuickstartUser(HttpUser):
    wait_time = between(0, 1)

    @task(1)
    def view_get_endpoint(self):
        self.client.get(
            "/get?show_env", headers={"X-Request-Id": uuid.uuid4().__str__()}
        )

    @task(1)
    def view_headers_endpoint(self):
        self.client.get(
            "/headers?show_env", headers={"X-Request-Id": uuid.uuid4().__str__()}
        )
