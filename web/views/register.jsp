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
    <title>Register</title>
</head>
<body>
<h1>Enter your data:</h1>
<form method="post">
    <label for="name">Name:</label>
    <input type="text" name="name" id="name" placeholder="Enter your name:">

    <label for="username">Username</label>
    <input type="text" name="username" id="username" placeholder="Enter your username:">

    <label for="password">Password:</label>
    <input type="password" name="password" id="password">

    <label for="birthdate">Bithdate:</label>
    <input type="date" name="birthdate" id="birthdate">

    <select name="gender">
        <option>Male</option>
        <option selected>Female</option>
    </select>
    <button type="submit">Ok</button>
</form>
</body>
</html>
