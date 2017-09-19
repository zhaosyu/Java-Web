<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ page import="entity.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" http-equiv='refresh' content='2;url=index.jsp'>
                                            <!-- //在这里填管理网站首页 -->
<title>账户已登录</title>
<link rel="stylesheet" href="css/login.css" />
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
</head>
<body class="loginbody">
<%
	User user = (User)session.getAttribute("login");
%>
<div id="loginPanel">
	<h1 id="title1">用户已登录</h1>
	<form  method="post" id="RegisterForm" style="text-align: center;">
		<table id="ttable" style="margin-left: auto;margin-right: auto;">
			<tr>
				<td style="padding: 20px;"><span><%= user.getDisplayName() %> 用户已登录，2秒后跳转至首页</span></td>
			</tr>
			<tr>
				<td><a href="index.jsp">>>>>立即前往首页>>>></a></td>
				<!-- //在这里填管理网站首页 -->
			</tr>
			<tr>
				<td><a href="doLogout.jsp">----退出登录----</a></td>
			</tr>			
		</table>
	</form>
</div>

</body>
</html>