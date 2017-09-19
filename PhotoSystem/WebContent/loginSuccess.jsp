<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="entity.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" http-equiv='refresh' content='2;url=index.jsp'>
                                     <!-- //在这里填管理网站首页 -->
<title>登陆成功</title>
<link rel="stylesheet" href="css/login.css" />
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script src="js/jquery.cookie.js" type="text/javascript"></script>
<script>$(function(){$.cookie('key', null);$.cookie('pClass',null);})</script>
</head>
<body class="loginbody">

<%
	User user = (User)session.getAttribute("login");
%>
<div id="loginPanel">
	<h1 id="title1">登录成功</h1>
	<form  method="post" id="RegisterForm" style="text-align: center;">
		<table id="ttable" style="margin-left: auto;margin-right: auto;">
			<tr>
				<td style="padding: 20px;"><span>登陆成功，欢迎 <%= user.getDisplayName() %> 回来！</span></td>
			</tr>
			<tr>
				<td><a href="#">>>>正在跳转至首页>>>></a></td>
				<!-- //在这里填管理网站首页 -->
			</tr>	
			<tr>
				<td><a href="changePassword.jsp">>>>修改密码>>>></a></td>
			</tr>		
		</table>
	</form>
</div>
</body>
</html>