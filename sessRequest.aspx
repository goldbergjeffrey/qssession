<%@ Page Language="C#" AutoEventWireup="true" debug="true"%>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Threading.Tasks" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Linq" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>
<%@ Import Namespace="System.Web.SessionState" %>

<!--
====================================================================================
File: sessRequest.aspx
Developer: Jeff Goldberg
Created Date: 14-July-2015

Description:
sessRequest.aspx is an asp.net web page to demonstrate using the Qlik Sense Session
API; a component of the Qlik Sense Proxy Service API (qps).  

WARNING!:
This code is intended for testing and demonstration purposes only.  It is not meant for
production environments.  In addition, the code is not supported by Qlik.

This code uses bootstrap for ui enhancement.  Bootstrap is delivered by urls.
If bootstrap CDN cannot be contacted, please download bootstrap (http://getbootstrap.com/)
and configure for this web page.

Change Log
Developer					Change Description						Modify Date
====================================================================================
Jeff Goldberg				Initial Release							14-July-2015


====================================================================================
====================================================================================
-->

<head>
	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
	<!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">

	<!-- Optional theme -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">

	<!-- Latest compiled and minified JavaScript -->
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script> 
	<style>
		/* centered columns styles */
		.row-centered {
		    text-align:center;
		}
		.col-centered {
		    display:inline-block;
		    float:none;
		    /* reset the text-align */
		    text-align:left;
		    /* inline-block space fix */
		    margin-right:-4px;
		}
	</style>
</head>
<html>
<body>
<form runat="Server" id="MainForm" class="form-horizontal">
	<div class="container">
		<div class="jumbotron" style="width: 950px; margin-top: 10px;">
			<H1 class="text-center" style="margin: -20 0 20 0;">Qlik Sense Session Example</H1>
			<div align="center" class="jumbotron" style="background-color: #F8F8F8; padding: 10px;">
				<p class="lead text-center">Start by getting a session from .Net</p>
				<p>
					<asp:Button id="btnGetSession" runat="server" Text="Create session variable" onclick="Go_Button_Session" class="btn btn-lg btn-success"></asp:Button>
				</p>
				<p>
					<asp:TextBox id="txtSession" runat="server" enabled="false" class="form-control text-center" width="250px" ></asp:TextBox>
				</p>
			</div>
			<div class="jumbotron" style="background-color: #F8F8F8; padding: 10px;">
				<p class="lead text-center">Create the session cookie and send to Qlik Sense</p>
				<div class="row row-centered">
					<div class="col-md-4 col-centered" >
						<div>
							<label for="txtServer" class="control-label">Sense Server</label>
							<asp:TextBox id="txtServer" runat="server" width="250px" class="form-control">Enter Qlik Sense Server Name</asp:TextBox>
						</div>
						<div>
							<label for="txtVp" class="control-label">Virtual Proxy</label>
							<asp:TextBox id="txtVp" runat="server" width="250px" class="form-control">Enter Virtual Proxy Name</asp:TextBox>
						</div>
					</div>
					<div class="col-md-4 col-centered">
						<div>
							<label for="txtUserDirectory" class="control-label">User Directory</label>
							<asp:TextBox id="txtUserDirectory" runat="server" width="250px" class="form-control">Enter User Directory</asp:TextBox>
						</div>
						<div>
							<label for="txtUser" class="control-label">User Id</label>
							<asp:TextBox id="txtUser" runat="server" width="250px" class="form-control">Enter UserId</asp:TextBox>
						</div>
					</div>
				</div>
				<div class="row row-centered" style="padding-top: 10px;">
					<asp:Button id="btnGo" runat="server" Text="Create Session in Qlik Sense" onclick="Go_Button_Click" class="btn btn-lg btn-primary"></asp:Button>
				</div>
			</div>
			<div class="container">
				<div class="row row-centered">
					<div class="jumbotron col-md-5 col-centered" style="background-color: #F8F8F8; padding: 10px;">
						<p class="lead text-center">The response</p>
						<div>
							<asp:TextBox id="sessResponse" runat="server" TextMode="multiline" class="form-control" height="150px"></asp:TextBox>
						</div>
					</div>
					<div class="col-md-2 col-centered" style="padding: 10px;">
						<div>
							<p class="lead text-center"></p>
						</div>
					</div>
					<div class="jumbotron col-md-5 col-centered" style="background-color: #F8F8F8; padding: 10px;">
						<p class="lead text-center">The cookie</p>
						<div>
							<asp:TextBox id="theCookie" runat="server" TextMode="multiline" class="form-control" height="150px"></asp:TextBox>
						</div>
					</div>
				</div>
			</div>
			<div class="jumbotron" style="background-color: #F8F8F8; padding: 10px;">
				<div class="row row-centered">
					<asp:Button id="btnLaunch" runat="server" Text="Go to Qlik Sense" onclick="Launch_Button_Click" class="btn btn-lg btn-success"></asp:Button>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>

<script language="c#" runat="server">

    private string SessionRequest(string method, string server, string virtualProxy, string user, string userdirectory)
    {
		X509Certificate2 certificateFoo =null;

        // First locate the Qlik Sense certificate
		X509Store store = new X509Store(StoreName.My, StoreLocation.LocalMachine);
        store.Open(OpenFlags.ReadOnly);
        certificateFoo = store.Certificates.Cast<X509Certificate2>().FirstOrDefault(c => c.FriendlyName == "QlikClient");
		store.Close();
		//The following line is required because the root certificate for the above server certificate is self-signed.
		//Using a certificate from a trusted root certificate authority will allow this line to be removed.
        ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };
		
		
        
		//Create URL to REST endpoint for tickets
        string url = "https://" + server + ":4243/qps/" + virtualProxy + "/session";

        //Create the HTTP Request and add required headers and content in Xrfkey
        string Xrfkey = "0123456789abcdef";
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url + "?Xrfkey=" + Xrfkey);
        request.ClientCertificates.Add(certificateFoo);    
        request.Method = method;
        request.Accept = "application/json";
        request.Headers.Add("X-Qlik-Xrfkey", Xrfkey);

        //The body message sent to the Qlik Sense Proxy api will add the session to Qlik Sense for authentication
        string body = "{ 'UserId':'" + user + "','UserDirectory':'" + userdirectory +"',";
		body+= "'Attributes': [],";
		body+= "'SessionId': '" + txtSession.Text + "'";
		body+= "}";
        byte[] bodyBytes = Encoding.UTF8.GetBytes(body);
        
        if (!string.IsNullOrEmpty(body))
        {
            request.ContentType = "application/json";
            request.ContentLength = bodyBytes.Length;
            Stream requestStream = request.GetRequestStream();
            requestStream.Write(bodyBytes, 0, bodyBytes.Length);
            requestStream.Close();
        }
                    
        // make the web request and return the content
        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
		Stream stream = response.GetResponseStream();
        return stream != null ? new StreamReader(stream).ReadToEnd() : string.Empty;
		
    }
	
	protected void Go_Button_Session(object sender, EventArgs e)
	{
		if(Page.IsPostBack)
		{
			//Create SessionID
			SessionIDManager Manager = new SessionIDManager();
			string NewID = Manager.CreateSessionID(Context);
			string OldID = Context.Session.SessionID;
			bool redirected = false;
			bool IsAdded = false;
			Manager.SaveSessionID(Context, NewID,out redirected, out IsAdded);
			txtSession.Enabled = true;
			txtSession.Text = NewID;
		}

	}

	protected void Go_Button_Click(object sender, EventArgs e)
	{
		//Create the session on the Qlik Sense server
		string sessionresponse= SessionRequest("POST", txtServer.Text, txtVp.Text, txtUser.Text, txtUserDirectory.Text);
		sessResponse.Text = sessionresponse;
		string[] getSessionArr = sessionresponse.Split(new Char[] {','});
		string[] getSessionCode = getSessionArr[3].Split(new Char[] {':'});
		
		//Create the cookie that will be used to complete the session authentication
		DateTime now = DateTime.Now;
		HttpCookie MyCookie = new HttpCookie("X-Qlik-Session-sessionvp");
		MyCookie.Value = getSessionCode[1].Trim(new Char[] {'"'});
		MyCookie.Expires = DateTime.MinValue;
		MyCookie.HttpOnly = true;
		//add the domain for the cookie to ensure the Qlik Sense server uses the cookie created by this page located on the IIS web server
		MyCookie.Domain = getDomain(txtServer.Text);

		//set the cookie to the request and response
		Request.Cookies.Add(MyCookie);
		Response.Cookies.Add(MyCookie);
		
		theCookie.Text = "Name: " + MyCookie.Name + Environment.NewLine;
		theCookie.Text += "Value: " + MyCookie.Value + Environment.NewLine;
		theCookie.Text += "Domain: " + MyCookie.Domain + Environment.NewLine;
		theCookie.Text += "Expiration: " + MyCookie.Expires + Environment.NewLine;
		theCookie.Text += "HttpOnly:" + MyCookie.HttpOnly + Environment.NewLine;
		theCookie.Text += "Secure:" + MyCookie.Secure + Environment.NewLine;
	}

	protected void Launch_Button_Click(object sender, EventArgs e)
	{
		//Redirect to the Qlik Sense server url desired
		Response.Redirect("https://" + txtServer.Text + "/" + txtVp.Text + "/hub/");
	}

	private string getDomain(string strServerAddress)
	{
		
		var pathElements = strServerAddress.Split('.');
		string result = null;

		for (int i=1;i<pathElements.Length;i++)
		{
			result+= pathElements[i] + ".";
		}
		result = result.TrimEnd(new[] {'.'});
		return result;
	}

</script>