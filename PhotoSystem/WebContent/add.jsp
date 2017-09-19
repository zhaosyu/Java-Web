<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*,entity.Photo,com.photo.util.PhotoFun"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="css/add.css" />
<!-- <script src="js/jquery-1.8.3.min.js"></script> -->
<script type="text/javascript" src="js/add.js"></script>
</head>
<body>
	<%
	String[] typeArr={"风景","人物","地点","事物","生活","工作","其他"};//存放所有类型
	if (request.getMethod().equals("POST")) {
		String topContent = "";
		String topic = "";
		String title = "";//照片标题
		String path = request.getRealPath("WEB-INF");
		Photo photo = null;
		request.setCharacterEncoding("utf-8");

		String pageNow = session.getAttribute("pageNow") != null ? (String)session.getAttribute("pageNow") : "1";
		String action=request.getParameter("action");
		if (action.equals("add")) {
			//添加操作
			topContent = "添加照片";
			topic = "标题<input type=\"text\" name=\"title\" id=\"\" />";

		} else if (action.equals("detail")) {
			//查看操作
			topContent = "照片详情";

			int id = Integer.parseInt(request.getParameter("id"));
			photo = PhotoFun.getPhotoById(id, path);
			topic = photo.getTitle();

		} else if (action.equals("update")) {
			//编辑操作
			topContent = "修改信息";

			int id = Integer.parseInt(request.getParameter("id"));
			photo = PhotoFun.getPhotoById(id, path);
			topic = "标题<input type=\"text\" name=\"title\" id=\"\" value=\"" + photo.getTitle() + "\"/>";

		}
	%>
	<div
		style="background-color: white; height: 570px; border-radius: 5px;"
		id="addPageDiv">
		<div id="header1">
			<div id="top">
				<div id="topcontent">
					<%=topContent%>
				</div>
			</div>
		</div>

		<form style="padding-top: 10px;" action="doUpload.jsp"
			enctype="multipart/form-data" method="post" onsubmit="return check_form()">
			<div id="content1">

				<div id="topic">
					<%=topic%>
				</div>

				<div id="addimage">
					<%
						if (!action.equals("add")) {
					%>
					<img src="<%=photo.getUrl()%>" id="uploadImg">
					<%
						} else {
					%>
					<div id="newimg">
						<img src="img/add.bmp" id="addimg">
					</div>
					<%
						}
					%>
				</div>
				<div id="describe">
					<%
						if (action.equals("detail")) {
							out.print("<span style='padding-top: 10px;display: block;'>"+photo.getType()+"</span>");
						} else {
					%>
					<div id="addPageOption" style='padding-top: 10px;display: block;'>
						<select id="type" name="leixing">
							<option value="" >请选择类别</option>
							<% 
								for(int i=0;i<typeArr.length;i++){
									%>
									<option value="<%=typeArr[i] %>" <%if(!action.equals("add") && typeArr[i].equals(photo.getType()))out.print("selected='selected'"); %>><%=typeArr[i] %></option>
									<%
								}
							%>
						</select>
					</div>	
					<%
						}
					%>
					
					<div>+============================+</div>
					<%
						if (action.equals("add")) {
					%>
					<textarea placeholder="请输入照片描述n内容"
						style="width: 320px; height: 210px;" name="description"></textarea>
					<%
						} else if (action.equals("detail")) {
					%>
					<p><%=photo.getDescribe()%></p>
					<%
						} else if (action.equals("update")) {
					%>
					<input type="hidden" name="id" value="<%=photo.getId()%>"/>
					<textarea placeholder="请输入照片描述n内容"
						style="width: 320px; height: 210px;" name="description">
								<%=photo.getDescribe()%>
							</textarea>
					<%
						}
					%>

				</div>
				<img src="img/transform1.png" id="transform_right" /> <img
					src="img/transform.png" id="transform_left" />
			</div>
			<%
				if (!action.equals("detail")) {
			%>
			<div style="width: 885px; text-align: center;">
				<input type="file" id="file" class="btn" name="nfile">
			</div>
			<%
				}
			%>
			<div id="button">
				<input type="submit" id="add" value="<%
					if(action.equals("add"))
						out.print("上传");
					else
						out.print("保存");
				%>" class="btn" name="actionType" <%
							if(action.equals("detail"))
								out.print("disabled='disabled' style='cursor: not-allowed;'");
						%>>
				<input type="button" id="back" value="返回" class="btn" onclick="location.href='index.jsp?pageNum=<%=pageNow %>'">

			</div>
		</form>
	</div>
	<%
				} else {
					response.sendRedirect("login.jsp");
				}
	%>

</body>
</html>