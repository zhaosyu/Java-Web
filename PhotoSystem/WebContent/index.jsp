<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>在线照片管理首页</title>
<link rel="stylesheet" href="css/index.css" />
<link rel="stylesheet" href="css/style.css" />
<script src="js/jquery-1.8.3.min.js"></script>
<script src="js/jquery.cookie.js" type="text/javascript"></script>
<script type="text/javascript" src="js/menu.js"></script>
<script type="text/javascript" src="js/header.js"></script>
</head>
<body>
<%if(session.getAttribute("login")==null)
  {
	response.sendRedirect("login.jsp");
  }else{
%>
	<%@ include file="header.jsp"%>
	<div id="content">

		<%@ include file="menu.jsp"%>

		<div id="right_side">
			<% //@include file="photoList.jsp" %>
		</div>
	</div>
		<%@ include file="footer.jsp" %>
		<%
  }
		%>
<!-- 	<script src="js/zoom.js"></script> -->
<iframe id="ModifyCameraForm" name="ModifyCameraForm" src="about:blank"  style="display:none;" width="1" height="1"></iframe>
</body>
</html>