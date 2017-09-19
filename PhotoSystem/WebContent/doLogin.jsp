<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="com.photo.util.LoginChecker" %>
<%@ page import="entity.User" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>

</head>
<body>
	<%
		request.setCharacterEncoding("utf-8");

		String username = request.getParameter("name");
		String password = request.getParameter("pwd");
		String captcha = request.getParameter("captcha");
		
		if(username == null || username.equals("")) {
			request.setAttribute("errorMessage", "用户名不能为空!");
			request.getRequestDispatcher("login.jsp").forward(request, response);
			return;
		}
		if(password == null || password .equals("")) {
			request.setAttribute("errorMessage", "密码不能为空!");
			request.getRequestDispatcher("login.jsp").forward(request, response);
			return;
		}
		
		if(captcha == null || captcha.equals("")) {
			request.setAttribute("errorMessage", "验证码不能为空!");
			request.getRequestDispatcher("login.jsp").forward(request, response);
			return;
		}
		String targetCaptcha = (String)session.getAttribute("captcha");
		if(!captcha.equals(targetCaptcha)) {
			request.setAttribute("errorMessage", "验证码不匹配!");
			request.getRequestDispatcher("login.jsp").forward(request, response);
			return;
		}
		
		String path = request.getRealPath("WEB-INF");
		User user = LoginChecker.checkLogin(path, username, password);
		
		if(user != null) {
// 			response.sendRedirect("loginSuccess.jsp");
			session.setAttribute("login", user);
			request.getRequestDispatcher("loginSuccess.jsp").forward(request, response);
		} else {
			request.setAttribute("errorMessage", "用户名密码不匹配！");
			request.getRequestDispatcher("login.jsp").forward(request, response);
			return;
		}
		
// 		out.println("你输入的用户名是：" + username + "<br/>");
// 		out.println("你输入的密码是：" + password);
		
// 		String[] hobbies = request.getParameterValues("hobby");

// 		out.println("你的兴趣是：");
// 		for(String hobby : hobbies) {
// 			out.println(hobby + "<br/>");
// 		}
	%>
</body>
</html>