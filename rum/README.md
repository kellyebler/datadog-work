# RUM Injection Script

A JavaScript snippet for injecting the Datadog Real User Monitoring (RUM) SDK into any web page via browser DevTools.

## Files

- `inject-rum.js` - Console-injectable RUM initialization script

## Usage

1. Open browser DevTools (F12 or Cmd+Shift+I)
2. Navigate to the Console tab
3. Paste the contents of `inject-rum.js`
4. Replace placeholder values:
   - `<CLIENT_TOKEN_HERE>` - Your RUM client token
   - `<APP_ID_HERE>` - Your RUM application ID
   - `<SITE>` - Datadog site (e.g., `datadoghq.com`, `datadoghq.eu`)
   - `<SERVICE>` - Service name
   - `<ENV>` - Environment name
5. Press Enter to execute

## Configuration Options

The script enables:
- **Session Sample Rate**: 100% (all sessions captured)
- **Session Replay**: 100% (all sessions recorded)
- **User Interactions**: Click, scroll, and input tracking
- **Resource Timing**: XHR, fetch, and asset load times
- **Long Tasks**: JavaScript execution blocking > 50ms
- **Privacy Level**: `allow` (captures all content)

## Use Cases

- Quick RUM testing on customer sites
- POC demonstrations without code changes
- Debugging RUM configuration issues

## Related Documentation

- [Datadog RUM Browser SDK](https://docs.datadoghq.com/real_user_monitoring/browser/)
- [RUM SDK Configuration](https://docs.datadoghq.com/real_user_monitoring/browser/setup/)
