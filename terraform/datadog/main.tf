terraform {
  required_providers {
        datadog = {
            source  = "DataDog/datadog"
        }
    } 
  cloud {
    organization = "kellyebler183451b6"
    workspaces {
      name = "datadog"
    }
  }
} 

provider "datadog" {
    api_key = var.datadog_api_key
    app_key = var.datadog_app_key
    # Optional: specify the Datadog site (e.g., datadoghq.com, datadoghq.eu)
    # api_url = "https://api.datadoghq.com/"
}

# Example Usage (Synthetics ICMP test)
# Create a new Datadog Synthetics ICMP test on example.org
resource "datadog_synthetics_test" "test_api_icmp" {
  name      = "ICMP Test on example.com"
  type      = "api"
  subtype   = "icmp"
  status    = "live"
  message = "Test message: ping test is failing"
  locations = ["aws:eu-central-1"]
  tags      = ["foo:bar", "foo", "env:test"]

  request_definition {
    host                    = "example.com"
    no_saving_response_body = "false"
    number_of_packets       = "1"
    persist_cookies         = "false"
    should_track_hops       = "false"
    timeout                 = "0"
  }

  assertion {
    operator = "is"
    target   = "0"
    type     = "packetLossPercentage"
  }

  assertion {
    operator = "lessThan"
    property = "avg"
    target   = "1000"
    type     = "latency"
  }

  assertion {
    operator = "moreThanOrEqual"
    target   = "1"
    type     = "packetsReceived"
  }
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 300
    }
    monitor_options {
      renotify_interval = 120
    }
  }
}