<%--
  Created by IntelliJ IDEA.
  User: user
  Date: 5/10/2024
  Time: 4:32 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" errorPage="error.jsp" %>

<html>
<head>
    <title>Title</title>
</head>
<body>

<h1>Enter your credentials</h1>
<form method="post" action="login.jsp">
    <label for="username">Username</label>
    <input type="text" name="username" id="username" placeholder="Enter your username:">

    <label for="password">Password</label>
    <input type="password" name="password" id="password">
</form>
</body>
</html>
