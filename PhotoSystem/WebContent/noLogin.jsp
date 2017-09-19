<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ page import="entity.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" http-equiv='refresh' content='3;url=login.jsp'>
<title>账户未登录</title>
<link rel="stylesheet" href="css/login.css" />
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
</head>
<body>
<div id="loginPanel">
	<h1> </h1>
	<form  method="post" id="RegisterForm" style="text-align: center;">
		<table style="margin-left: auto;margin-right: auto;">
			<tr>
				<td style="padding: 20px;"><span>您未登录，请先登录</span></td>
			</tr>
			<tr>
				<td><a href="login.jsp">>>>>前往登录>>>></a></td>
			</tr>		
		</table>
	</form>
</div>

</body>
</html>