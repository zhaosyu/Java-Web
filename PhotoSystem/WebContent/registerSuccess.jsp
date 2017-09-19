<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="entity.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" http-equiv='refresh' content='3;url=login.jsp'>
<title>注册成功</title>
<link rel="stylesheet" href="css/login.css" />
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
</head>
<body class="loginbody">
<%
	User user = (User)session.getAttribute("login");
%>
<div id="loginPanel">
	<h1 id="title1">注册成功</h1>
	<form  method="post" id="RegisterForm" style="text-align: center;">
		<table id="ttable" style="margin-left: auto;margin-right: auto;">
			<tr>
				<td style="padding: 20px;"><span>恭喜 <%= user.getDisplayName() %>，成为我们的一员！</span></td>
			</tr>
			<tr>
				<td><a href="login.jsp">>>>正在跳转至登录页面>>>></a></td>
			</tr>			
		</table>
	</form>
</div>
<%
	session.invalidate();
%>
</body>
</html>