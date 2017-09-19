<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="entity.User"%>
<%
	User user = (User) session.getAttribute("login");
%>


<div id="headerback">
	<div id="header">
		<div id="logo">
			<img src="img/logo.png" />
		</div>
		<div id="searchbar">
			<input type="text" name="searchbar" placeholder="请输入照片标题" />
		</div>
		<div id="btn">
			<input type="button" value="搜索" class="btn searchBtn" />
		</div>
		<div id="username">
			<span>Hello <%=user.getLoginName()%> !
			</span> <span><a href="changePassword.jsp">修改密码</a></span><span><a
				href="doLogout.jsp">退出</a></span>
		</div>
	</div>
</div>

