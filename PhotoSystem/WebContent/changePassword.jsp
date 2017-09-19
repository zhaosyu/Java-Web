<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="entity.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>更改密码</title>
<link rel="stylesheet" href="css/login.css" />
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript">
	var count = 0;
	$(function(){
		$("#captchaImg").attr("src", "captcha.jsp?param=0");

		$("#captchaImg").bind("click", function(){
			$("#captchaImg").attr("src", "captcha.jsp?param=" + (++count));
		});
	});
</script>
</head>
<body class="loginbody">
<% 
	User user = (User) session.getAttribute("login"); 
	if(user != null) {
%> 
<div id="loginPanel">
	<h1 id="title1">更改密码</h1>
	<form action="doChangePassword.jsp" method="post" id="RegisterForm">
		<table id="ttable">
			<%
				String errMsg = (String)request.getAttribute("errorMessage");
				String username = user.getLoginName();
				if(errMsg != null) {
			%>
			<tr>
				<td colspan="2" class="errorM">
					<span class="errorMessage"><%= errMsg %></span>
				</td>
			</tr>
			<%
				}
			%>
			<tr>
				<td class="word">输入原密码：</td>
				<td>
					<input type="password" name="ypwd" class="kuang"/>
				</td>
			</tr>
			<tr>
				<td class="word">输入新密码：</td>
				<td><input class="kuang" type="password" name="npwd"/></td>
			</tr>
			<tr>
				<td class="word">确认新密码：</td>
				<td><input class="kuang" type="password" name="qpwd"/></td>
			</tr>
			<tr>
				<td class="word">验证码：</td>
				<td><input class="kuang" type="text" name="captcha" /></td>
			</tr>
			<tr>
				<td colspan="2" class="captchaImg"><img src="" alt="" id="captchaImg"/></td>
			</tr>
			
			<tr>
				<td colspan="3" class="buttons btn"> <input type="reset" value="重置" class="btn"/><input type="submit" value="确定" class="btn" /><input onclick="window.location.href='index.jsp'" type="button" value="取消" class="btn"/> </td>
     <!-- 右边有网页要填 -->                                                                <!-- 				                                                                                                           这里输网站首页名 -->
			</tr>
		</table>
	</form>
</div>
<%
	} else {
		response.sendRedirect("noLogin.jsp");
	}
%>


</body>
</html>