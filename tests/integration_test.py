import http
import json
import uuid
from http.client import HTTPConnection

igw_endpoint = "localhost:10000"


def test_nginx_should_proxy_tracing_headers():
    # Given
    x_request_id = uuid.uuid4().__str__()
    x_session_id = uuid.uuid4().__str__()
    connection = http.client.HTTPConnection(igw_endpoint)

    # When I make an HTTP request to the Ingress Gateway
    # mimicking Envoy's behaviour by passing through
    # the x-request-id header. And also supplying
    # an x-session-id header (which seems to be prevalent)
    # on the platform.

    connection.request(
        "GET",
        # ?show_env = https://github.com/postmanlabs/httpbin/issues/454#issuecomment-390414420
        f"http://{igw_endpoint}/get?show_env",
        headers={"X-Request-Id": x_request_id,
                 "X-Session-Id": x_session_id}
    )
    response = connection.getresponse()

    # Then NGINX should proxy both the headers when it calls
    # the configured upstream. In this case the upstream is httpbin
    # which provides details of the received headers in the HTTP
    # response body.

    assert response.getcode() == 200
    json_response_body = json.loads(response.read())
    # Why doesn't this header get proxied?!
    assert json_response_body["headers"]["X-Request-Id"] == x_request_id
    assert json_response_body["headers"]["X-Session-Id"] == x_session_id
