<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="config.jsp"%>
<%@page import="com.photo.util.*,entity.*"%>
<%@page import="java.util.*"%>
<!DOCTYPE html>
<html dir="ltr" lang="en-US">
<head>
<meta charset="UTF-8" />
<title>照片管理系统</title>
<link rel="stylesheet" href="css/photoList.css" />
<link rel="stylesheet" href="css/zoom.css" media="all" />
</head>
<body>
	<%
//		if (session.getAttribute("login") != null) {
			if (request.getMethod().equals("POST")) {
				User userp = (User)session.getAttribute("login");
				int userID=userp.getId();
				
				request.setCharacterEncoding("utf-8");
				String pageNow = "1";

				if (request.getParameter("pageNum") != null) {
					try {
						pageNow = request.getParameter("pageNum").equals("") ? "1"
								: request.getParameter("pageNum");
					} catch (Exception e) {
					}
				}


				String path = request.getRealPath("WEB-INF");
				String pClass = "全部";
				String action = request.getParameter("action") != null ? request.getParameter("action") : "";
				String id = request.getParameter("id") != null ? request.getParameter("id")
						: request.getParameter("imgids");

				pClass = request.getParameter("pClass") != null ? request.getParameter("pClass") : pClass;
				String key = "";
				if (request.getParameter("key") != null)
					key = request.getParameter("key").equals("null") ? "" : request.getParameter("key");

				if (action.contains("del") && PhotoFun.deleteImg(action, id, path)) {
					//删除成功
					//				out.print("删除成功");
				} else if (action.equals("class")) {
					//分类
					//out.print("分类");
				} else {
					out.print("false");
				}
				//		}
				//		if (flag) {
				//获取总条数
				int totalCount = PhotosGetter.getPhotosCount(path, pClass, key,userID);

				Page pages = new Page();
				pages.setPageSize(6); //设置每页条数
				pages.setTotalCount(totalCount); //设置总记录数
				int totalPages = pages.getTotalPageCount();
				int pageIndex = Integer.parseInt(pageNow);//1;
				try {
					pageIndex = Integer.parseInt(pageNow);
				} catch (Exception e) {
				}

				/*对首页与末页越界进行控制*/
				if (pageIndex < 1) {
					pageIndex = 1;
				} else if (pageIndex > pages.getTotalPageCount()) {
					pageIndex = totalPages;
				}
				pages.setCurrPageNo(pageIndex); //设置当前页面

				List<Photo> photosList = null;

				//无title查询
				if (key.equals(""))
					photosList = PhotosGetter.getPagedPhotosList(path, pageIndex, 6, pClass,userID);
				else
					photosList = PhotoFun.SearchPagedPhotoByTitle(key, path, pageIndex, 6, pClass,userID);
				//out.print(pages.getCurPageCount());
	%>
	<div class="container" style="margin-top: 1em; background: white;">
		<input type="hidden" name="pageListNow" value="<%=pageNow%>>" />
		<div class="right_side_header">
			<table>
				<tr>
					<td><%=pClass%>(<%=totalCount%>条)</td>
					<td class="midTitle">我的照片展览</td>
					<td><span>全选：</span><input type="checkbox" name="selectAll"
						id="selectAll" /> <input type="button" value="删除" id="deleteMany"
						class="btn" /></td>
				</tr>
			</table>
		</div>
		<div class="gallery">
			<%
				//循环下列图片

						for (int i = 0; i < pages.getCurPageCount(); i++) {
			%>
			<div class="ss">
				<table>
					<tr>
						<td><a href="<%=photosList.get(i).getUrl()%>"> <img
								src="<%=photosList.get(i).getUrl()%>" /></a> <input type="hidden"
							value="<%=photosList.get(i).getId()%>" class="imgid" /></td>
						<td><input type="checkbox" name="include"
							class="selectId <%=photosList.get(i).getId()%>" /> <span
							class="photoListEdit">编辑</span> <span class="photoListDownLoad">下载</span></td>
					</tr>
					<tr>
						<td colspan="2">
							<ul class="photoListCon <%=photosList.get(i).getId()%>">
								<li><%=photosList.get(i).getTitle()%></li>
								<li><%=photosList.get(i).getTime().split(" ")[0]%></li>
							</ul>
						</td>
					</tr>
				</table>

			</div>
			<%
				}
						if (pages.getCurPageCount() == 0) {
			%>
			<span style="color: red; width: 885px; display: block">没有照片了，赶紧去添加吧~</span>
			<%
				}
						//结束
			%>
		</div>
		<div class="right_side_footer">
			<%
				//获取当前完整url,并且处理
				String WebUrl ="index.jsp?";
				if(!key.equals(""))
					WebUrl +="key=" + key + "&";
			%>
			当前页数：[<%=pageIndex%>/<%=totalPages%>]
			<%
				if (pageIndex > 1) { //如果当前不是第一页
			%>
			<a href="<%=WebUrl%>pageNum=1">首页</a>&nbsp; <a
				href="<%=WebUrl%>pageNum=<%=pageIndex - 1%>">上一页</a>
			<%
				}
						if (pageIndex < totalPages) { //当前不是最后一页
			%>
			<a href="<%=WebUrl%>pageNum=<%=pageIndex + 1%>">下一页</a> <a
				href="<%=WebUrl%>pageNum=<%=totalPages%>">末页</a>
			<%
				}
			%>

		</div>
	</div>
	<%
		}else
			response.sendRedirect("index.jsp");
	%>
	<img id="delete" src="img/iconfont-delete.png" />

<!-- 	<script src="js/jquery-1.8.3.min.js"></script> -->
	<script src="js/zoom.js"></script>
	<script src="js/photoList.js"></script>
</body>
</html>