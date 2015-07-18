<h2>Description</h2>
sessRequest.aspx is an asp.net web page to demonstrate using the Qlik Sense Session
API; a component of the Qlik Sense Proxy Service API (qps).  

<strong>WARNING!</strong>
This code is intended for testing and demonstration purposes only.  It is not meant for
production environments.  In addition, the code is not supported by Qlik.

This code uses bootstrap for ui enhancement.  Bootstrap is delivered by urls.
If bootstrap CDN cannot be contacted, please download bootstrap (http://getbootstrap.com/)
and configure for this web page.

<h2>Certificate Configuration</h2>
The qps requires https to provide session information to the browser.  This demonstration uses the QlikClient certificate supplied during Qlik Sense installation to secure connectivity.  It is possible to use the server certificate as well, but in both cases the certificate must include the private key.

Install the certificate to the Personal folder under the Local Machine certificate store of the web server the aspx page will be hosted.
From the certificates snap-in right click the installed certificate and select Manage Private Keys.  Add the application pool account used to host the web page (e.g. IIS AppPool\DefaultAppPool) to the list of users and click Apply.

<h2>Virtual Proxy Configuration</h2>
For this code sample, the virtual proxy needs to be configured in a specific way because of variable usage.  Make sure the Prefix and the Session cookie header name are set the same way.  Put another way, the name of the prefix needs to appear at the end of the Session cookie header name where the cookie name == X-Qlik-Session-%virtualProxyPrefix%.

Please use the following image as a guide.
<img src="sessionVP.png"></img>


It is now possible to test the code.
