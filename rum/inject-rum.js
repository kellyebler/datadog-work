// Paste this directly into devtools console to inject the RUM agent
// This script will inject the RUM agent into the current page.

i(function(h,o,u,n,d) {
    h=h[d]=h[d]||{q:[],onReady:function(c){h.q.push(c)}}
    d=o.createElement(u);d.async=1;d.src=n
    n=o.getElementsByTagName(u)[0];n.parentNode.insertBefore(d,n)
  })(window,document,'script','https://www.datadoghq-browser-agent.com/us1/v5/datadog-rum.js','DD_RUM')
  window.DD_RUM.onReady(function() {
    window.DD_RUM.init({
      clientToken: '<CLIENT_TOKEN_HERE>', // <-- replace this with your client token
      applicationId: '<APP_ID_HERE>', // <-- replace this with your application ID
      site: '<SITE>', // <-- replace this with your site
      service: '<SERVICE>', // <-- replace this with your service name
      env: '<ENV>', // <-- replace this with your environment
      // Specify a version number to identify the deployed version of your application in Datadog
      // version: '1.0.0', 
      sessionSampleRate: 100,
      sessionReplaySampleRate: 100,
      trackUserInteractions: true,
      trackResources: true,
      trackLongTasks: true,
      defaultPrivacyLevel: 'allow',
    });
  })
