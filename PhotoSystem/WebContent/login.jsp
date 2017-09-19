<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="entity.User" %>
<!DOCTYPE html>
<html>
<head>
<meta  http-equiv="Content-Type" content="text/html;charset=UTF-8">
<title>登录</title>
<link rel="stylesheet" href="css/login.css" />
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script src="js/jquery.cookie.js" type="text/javascript"></script>
<script type="text/javascript">
	var count = 0;
	
	$(function(){
		$("#captchaImg").attr("src", "captcha.jsp?param=0");

		$("#captchaImg").bind("click", function(){
			$("#captchaImg").attr("src", "captcha.jsp?param=" + (++count));
		});
		if($.cookie('loginName')!='null'){
			$("input[name=name]").val($.cookie('loginName'));
			$("#rmbn").attr("checked",true);
		}
		if($.cookie("pwd")!='null'){
			$("input[name=pwd]").val($.cookie("pwd"));
			$("#rmbpwd").attr("checked",true);
		}
		$("#denglu").click(function(){
			if($("#rmbn").is(":checked")){
				$.cookie('loginName',$("input[name=name]").val());
			}else
				$.cookie('loginName',null);
			if($("#rmbpwd").is(":checked")){
				$.cookie('pwd',$("input[name=pwd]").val());
			}else
				$.cookie('pwd',null);
		});
	});
</script>
<%
// 	String username1="";
// 	String password1="";
// 	Cookie[] cookies = request.getCookies();
// 	for(int i = 0;i<cookies.length;i++){
// 		if("username1".equals(cookies[i].getName())){
// 			username1 = cookies[i].getValue();
// 		}else if("password1".equals(cookies[i].getName())){
// 			password1 = cookies[i].getValue();
// 		}
// 	}
%>
</head>
<body class="loginbody">
<% 
	User user = (User) session.getAttribute("login"); 
	if(user == null) {
		String errMsg = (String)request.getAttribute("errorMessage");
		String username = request.getParameter("name");
		session.setAttribute("rmb", user);
%>

<div id="loginPanel">
	<h1 id="title1">用户登录</h1>
	<form action="doLogin.jsp" method="post" id="loginForm">
		<table id="ttable">
			<%
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
				<td><input type="password" class="kuang"  name="pwd" /></td>
			</tr>
			<tr>
				<td class="word">验证码：</td>
				<td><input type="text" class="kuang" name="captcha" /></td>
			</tr>
			<tr>
				<td colspan="2" class="captchaImg"><img src="" alt="" id="captchaImg"/></td>
			</tr>
			<tr>
				<td colspan="2" class="rmb">
					<input type="checkbox" name="rmb" id="rmbn" value="remembername" />记住用户名
					<input type="checkbox" name="rmb" id="rmbpwd" value="remenberpassword"/>记住密码

				</td>
			</tr>
			<tr>
				<td colspan="2" class="buttons btn"> <input type="reset" value="重置" class="btn" id="lllllll" />
				<input type="button" value="注册" onclick="location.href='register.jsp'" class="btn"/>
				<input type="submit" value="登录" id="denglu" class="btn"/> 				
			</td>
			</tr>
		</table>
	</form>
</div>
<%
	} else {
		response.sendRedirect("isLogin.jsp");


	}
%>


</body>
</html>