import http
import http.client
import json
import os

if "IN_CONTAINER" in os.environ:
    igw_hostname = "igw"
else:
    igw_hostname = "localhost"
igw_endpoint = f"{igw_hostname}:10000"


def test_it_proxies_api_gateway_requests_to_the_appropriate_microservices():
    # Given
    # An incoming HTTP request with a host in the form: <microservice-name>.<environment>.tax.service.gov.uk
    microservice_name = "platform-status-backend"
    incoming_host = f"{microservice_name}.production.tax.service.gov.uk"

    connection = http.client.HTTPConnection(igw_endpoint)

    # When I make an HTTP request to the Ingress Gateway NGINX service.
    connection.request(
        "GET",
        f"http://{incoming_host}:10000/get",
    )
    response = connection.getresponse()

    # Then NGINX should perform the appropriate proxy rewrite
    # calling an upstream in the form <microservice-name>.protected.mdtp.
    expected_rewritten_host = f"{microservice_name}.protected.mdtp"
    assert response.getcode() == 200
    json_response_body = json.loads(response.read())
    assert json_response_body["headers"]["Host"] == expected_rewritten_host


def test_it_should_use_the_default_server_for_requests_which_do_not_originate_from_api_gateway():
    # Given
    connection = http.client.HTTPConnection(igw_endpoint)

    # When I make an HTTP request to the Ingress Gateway
    # using a hostname which does not match the pattern used
    # by requests originating by API Gateway
    connection.request(
        "GET",
        f"http://{igw_endpoint}/get",
    )
    response = connection.getresponse()

    # Then NGINX should proxy the call using the default server configuration.
    # which we can determine heuristically by looking at the "Host" header
    # value returned by HTTPBin.
    assert response.getcode() == 200
    json_response_body = json.loads(response.read())
    assert json_response_body["headers"]["Host"] == igw_hostname
