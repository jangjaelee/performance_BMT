<%@ page contentType="text/html; charset=euc-kr" %>
<%@ page import="java.util.*" %>
<HTML>
<HEAD>
<TITLE>JSP WORKLOAD TEST</TITLE>
</HEAD>
<BODY>
<%
long i=1;
long j=1;
long result=0;
long startTime;
long endTime;

out.println("<p><br><br></p>");
out.println("This web server name is " + application.getServerInfo());
out.println("<p>&nbsp;</p>");

startTime = System.currentTimeMillis();

for(i=1; i<=10; i++) {
        for(j=1; j<=1000000; j++) {
                result=i*j;
        }
}

endTime = System.currentTimeMillis();

out.println("Page generated in " + (endTime - startTime) / 1000.0 + "sec");
%>
</BODY>
</HTML>
