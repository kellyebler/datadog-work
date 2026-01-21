# Datadog Agent Configuration Templates

Minimal, well-documented configuration files for Datadog Agent integrations. These templates strip away the noise from the full example configs and highlight commonly-used parameters.

## Files

```
agent/
├── minimal-agent.yaml       # Main datadog.yaml template
└── conf.d/
    ├── postgres.d/
    │   └── conf.yaml        # PostgreSQL DBM configuration
    └── rabbitmq.d/
        └── conf.yaml        # RabbitMQ integration
```

## minimal-agent.yaml

A starting point for the main Datadog Agent configuration with:
- API key placeholder
- Proxy configuration (commented)
- Global tags setup
- Log collection enabled
- Live Process monitoring enabled

### Installation Location

| OS | Path |
|----|------|
| Linux | `/etc/datadog-agent/datadog.yaml` |
| Windows | `%ProgramData%\Datadog\datadog.yaml` |
| macOS | `~/.datadog-agent/datadog.yaml` |

## Integration Configurations

### PostgreSQL (DBM)

`conf.d/postgres.d/conf.yaml` - Configured for Database Monitoring with:
- DBM enabled
- Database autodiscovery
- Explain plan collection settings

See also: `../postgres/verify.sh` for permission verification.

### RabbitMQ

`conf.d/rabbitmq.d/conf.yaml` - Basic RabbitMQ monitoring via the management API.

## Usage

1. Copy the main config:
   ```bash
   sudo cp minimal-agent.yaml /etc/datadog-agent/datadog.yaml
   ```

2. Copy integration configs:
   ```bash
   sudo cp -r conf.d/* /etc/datadog-agent/conf.d/
   ```

3. Update placeholder values in each file

4. Restart the agent:
   ```bash
   sudo systemctl restart datadog-agent
   ```

## Related Documentation

- [Agent Configuration Files](https://docs.datadoghq.com/agent/guide/agent-configuration-files/)
- [Full Config Template](https://github.com/DataDog/datadog-agent/blob/main/pkg/config/config_template.yaml)
