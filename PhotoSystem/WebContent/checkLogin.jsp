<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
	Object obj = session.getAttribute("login");
	if(obj == null) {
		response.sendRedirect("login.jsp");
	}
%>