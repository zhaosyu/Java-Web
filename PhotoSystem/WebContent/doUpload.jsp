<%@page import="entity.User"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@page import="java.io.*,java.util.*"%>
<%@page import="org.apache.commons.fileupload.*"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="com.photo.util.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%
		if (session.getAttribute("login") != null) {
			User user = (User) session.getAttribute("login");
	%>
	<%!String makeFileName(String filename) {
		return UUID.randomUUID().toString() + "_" + filename;
	}%>
	<%
		request.setCharacterEncoding("utf-8");

			//上传文件的存储路径（服务器文件系统上的绝对文件路径）
			String uploadFilePath = request.getSession().getServletContext().getRealPath("uploadPhoto/");

			boolean uploaded = false;
			String uploadFileName = ""; //上传的文件名
			String fieldName = ""; //表单字段元素的name属性值
			String description = "";
			String pClass = "";
			String title = "";
			String err = "错误：";
			String path = request.getRealPath("WEB-INF");
			String actionType = "";
			int id = 0;
			//通过Arrays类的asList()方法创建固定长度的集合
			List<String> fileType = Arrays.asList("gif", "bmp", "jpg", "png");

			//请求信息中的内容是否是multipart类型
			boolean isMultipart = ServletFileUpload.isMultipartContent(request);
			if (isMultipart) {
				FileItemFactory factory = new DiskFileItemFactory();
				ServletFileUpload upload = new ServletFileUpload(factory);
				try {
					//解析form表单中所有文件
					List<FileItem> items = upload.parseRequest(request);
					Iterator<FileItem> iter = items.iterator();
					while (iter.hasNext()) { //依次处理每个文件
						FileItem item = (FileItem) iter.next();
						if (item.isFormField()) { //普通表单字段
							fieldName = item.getFieldName(); //表单字段的description属性值
							if (fieldName.equals("description")) {
								description = item.getString("UTF-8");
								//输出表单字段的值
								out.print("文件描述：" + description + "<br/>");
							}
							if (fieldName.equals("leixing")) {
								pClass = item.getString("UTF-8");
								//输出表单字段的值
								out.print("类型：" + pClass + "<br/>");
							}
							if (fieldName.equals("title")) {
								title = item.getString("UTF-8");
								//输出表单字段的值
								out.print("标题：" + title + "<br/>");
							}
							if (fieldName.equals("actionType")) {
								actionType = item.getString("UTF-8");
								//输出表单字段的值
								out.print("操作：" + actionType + "<br/>");
							}
							if (fieldName.equals("id")) {
								id = Integer.parseInt(item.getString("UTF-8"));
								//输出表单字段的值
								out.print("操作：" + id + "<br/>");
							}
						} else { //文件表单字段

							String fileName = item.getName();
							if (fileName != null && !fileName.equals("")) {
								String ext = fileName.substring(fileName.lastIndexOf(".") + 1);
								if (!fileType.contains(ext)) { //判断文件类型是否在允许范围内
									out.print("上传失败，文件类型只能是gif、bmp、jpg <br/>");
								} else {
									if (item.getSize() <= 1000 * 1000) {
										File fullFile = new File(makeFileName(item.getName()));
										File saveFile = new File(uploadFilePath, fullFile.getName());
										item.write(saveFile);
										uploaded = true;
										uploadFileName = fullFile.getName();
									} else {
										//out.print("上传失败，文件大小必须小于1MB<br/>");
										err += "上传失败，文件大小必须小于1MB<br/>";
									}
								}
							}
						}
					}
				} catch (Exception e) {
					//e.printStackTrace();
				}
			}

			if (uploaded == true || err.equals("错误：")) {
				//url:uploadFileName,descb:description
				String fileUrl = "uploadPhoto/" + uploadFileName;
				if (uploadFileName.equals(""))
					fileUrl = "";
				if (actionType.equals("上传"))
					PhotoFun.uploadPhoto(pClass, title, fileUrl, description, path, user.getId());
				if (actionType.equals("保存"))
					PhotoFun.updatePhoto(id, pClass, title, fileUrl, description, path);
				out.print("<script>alert('操作成功" + uploadFileName + "')</script>");
			} else {
				out.print("<script>alert('" + err + "')</script>");
			}
			//response.sendRedirect("index.jsp");
			response.setHeader("Refresh", "0.1;URL=index.jsp");
	%>
	<%
		}
	%>
</body>
</html>