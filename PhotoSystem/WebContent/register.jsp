<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="entity.User" %>
<%-- <%@ page import="com.rainsia.captcha.CaptchaGenerator" %> --%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>注册</title>
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
<div id="loginPanel">
	<h1 id="title1">用户注册</h1>
	<form action="doregister.jsp" method="post" id="RegisterForm">
		<table id="ttable">
			<%
				String errMsg = (String)request.getAttribute("errorMessage");
				String username = request.getParameter("name");
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
				<td class="word">用户名：</td>
				<td>
					<input type="text" class="kuang" name="name" value="<%= username==null?"":username %>"/>
				</td>
			</tr>
			<tr>
				<td class="word">密码：</td>
				<td><input type="password" class="kuang" name="pwd"/></td>
			</tr>
			<tr>
				<td class="word">确认密码：</td>
				<td><input type="password" class="kuang" name="qpwd"/></td>
			</tr>
			<tr>
				<td class="word">验证码：</td>
				<td><input type="text" class="kuang" name="captcha" /></td>
			</tr>
			<tr>
				<td colspan="2" class="captchaImg"><img src="" alt="" id="captchaImg"/></td>
			</tr>
			
			<tr>
				<td colspan="3" class="buttons btn"> <input type="reset" value="重置" class="btn" /><input type="submit" value="确定" class="btn"/><input type="button" value="取消" onclick="location.href='login.jsp'" class="btn"/> </td>
			</tr>
		</table>
	</form>
</div>


</body>
</html>