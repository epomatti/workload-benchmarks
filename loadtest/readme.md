Set the target environment:

```sh
# For local testing
export K6_HOST="http://localhost:5187"

# For testing in the cloud
export K6_HOST="https://app-benchmark-dotnet999.azurewebsites.net"
```

Run the test - change the loading parameters as per requirement:

> ⚠️ To avoid public connection interference it is recommended to do load testing with origin restrictions from your source IP, or use the jumpbox VM that is provisioned as part of the Terraform scripts.

```ps1
k6 run --vus 200 --duration 120s pets.js
```

