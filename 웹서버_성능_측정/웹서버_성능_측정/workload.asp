<HTML>
<HEAD>
<TITLE>ASP WORKLOAD TEST</TITLE>
</HEAD><BODY>
<%
Response.Write "<p><br><br></p>" 
Response.Write "This web server name is " & (Request.ServerVariables("server_software"))
Response.Write "<p>&nbsp;</p>"

'Set objWSHNetwork = Server.CreateObject("WScript.Network") 
'  Response.Write objWSHNetwork.ComputerName

StartTimer = Timer()

dim i, j, result

for i=1 to 10
	for j=1 to 1000000
		result = i * j
		'Response.Write result & " = " & i & " * " & j
	next
next

Response.Write "Page generated in " & FormatNumber(Timer() - StartTimer, 3) & "sec"
%>
</BODY>
</HTML>