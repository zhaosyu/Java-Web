<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="com.photo.util.changepwd" %>
<%@ page import="entity.*" %>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%
		request.setCharacterEncoding("utf-8");
		User users = (User) session.getAttribute("login"); 
		String username = users.getLoginName();

		String oldpassword = request.getParameter("ypwd");
		String newpassword = request.getParameter("npwd");
		String qpassword = request.getParameter("qpwd");
		String captcha = request.getParameter("captcha");
  
		if(oldpassword == null || oldpassword.equals("")) {
			request.setAttribute("errorMessage", "请输入原密码!");
			request.getRequestDispatcher("changePassword.jsp").forward(request, response);
			return;
		}
		if(newpassword == null || newpassword .equals("")) {
			request.setAttribute("errorMessage", "密码不能为空!");
			request.getRequestDispatcher("changePassword.jsp").forward(request, response);
			return;
		}
		if(qpassword == null || qpassword .equals("")) {
			request.setAttribute("errorMessage", "请确认密码!");
			request.getRequestDispatcher("changePassword.jsp").forward(request, response);
			return;
		}
		if(captcha == null || captcha.equals("")) {
			request.setAttribute("errorMessage", "验证码不能为空!");
			request.getRequestDispatcher("changePassword.jsp").forward(request, response);
			return;
		}
		if(!newpassword.equals(qpassword)) {
			request.setAttribute("errorMessage", "两次输入密码不匹配!");
			request.getRequestDispatcher("changePassword.jsp").forward(request, response);
			return;
		}
		String targetCaptcha = (String)session.getAttribute("captcha");
		if(!captcha.equals(targetCaptcha)) {
			request.setAttribute("errorMessage", "验证码不匹配!");
			request.getRequestDispatcher("changePassword.jsp").forward(request, response);
			return;
		}
		String path = request.getRealPath("WEB-INF");
	
		User4 user4 = changepwd.ChangePwd(path, username, oldpassword, newpassword);
		
		if(user4 != null) {
// 			response.sendRedirect("loginSuccess.jsp");
			session.setAttribute("login", user4);
//  		String sql = "insert"+ user+"  from user ";
			request.getRequestDispatcher("changeSuccess.jsp").forward(request, response);
		} else {
			request.setAttribute("errorMessage", "原密码错误！请重试");
			request.getRequestDispatcher("changePassword.jsp").forward(request, response);
			return;
		}
		
// 			response.sendRedirect("loginSuccess.jsp");
		
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