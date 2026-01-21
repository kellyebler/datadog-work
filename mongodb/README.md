# MongoDB Integration Configuration

Example configuration file for the Datadog MongoDB integration with TLS enabled.

## Files

- `mongo-conf.yaml` - Minimal MongoDB conf.yaml with TLS settings

## Usage

1. Copy the configuration to your agent's conf.d directory:
   ```bash
   # Linux
   cp mongo-conf.yaml /etc/datadog-agent/conf.d/mongo.d/conf.yaml
   ```

2. Update the placeholder values:
   - `<HOST>` - MongoDB server hostname
   - `<PORT>` - MongoDB port (default: 27017)
   - `<USERNAME>` - Database user with monitoring permissions
   - `<PASSWORD>` - User password
   - `<SERVICE>` - Service name for unified tagging

3. Ensure `logs_enabled: true` is set in your main `datadog.yaml`

4. Verify the ddagent user has read permissions on log files

5. Restart the Datadog Agent:
   ```bash
   sudo systemctl restart datadog-agent
   ```

## Notes

The TLS settings (`tls: true`, `tls_allow_invalid_certificates: true`) were required for a specific POC environment. Adjust based on your MongoDB connection string requirements.

## Related Documentation

- [Datadog MongoDB Integration](https://docs.datadoghq.com/integrations/mongo/)
