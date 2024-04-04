### Install Grafana Agent (Ubuntu)

Follow steps outlined in the [docs](https://grafana.com/docs/agent/latest/static/set-up/install/install-agent-linux/)


### Configure Grafana agent to send to Grafana Cloud

Update the `etc/default/grafana-agent` to not user localhost server.

```
## Path:
## Description: Grafana Agent monitoring agent settings
## Type:        string
## Default:     ""
## ServiceRestart: grafana-agent
#
# Command line options for grafana-agent
#
# The configuration file holding the agent config
CONFIG_FILE="/etc/grafana-agent.yaml"

# Any user defined arguments
CUSTOM_ARGS=""
#-server.http.address=127.0.0.1:9090 -server.grpc.address=127.0.0.1:9091"

# Restart on system upgrade. Default to true
RESTART_ON_UPGRADE=true
```
