<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page language="java"
	import="java.io.IOException,java.io.FileOutputStream,java.io.File,java.io.InputStream,java.net.URL,java.net.URLConnection,java.io.OutputStream"
	pageEncoding="UTF-8"%>

<html>
<head>
<title>Index</title>
</head>
<body>
	<%
		request.setCharacterEncoding("UTF-8");
		String path = request.getParameter("path"); //ftp路径url//
		//因为tomcat的server.xml中的connector中是否配置URIEncoding的值，不配置默认为iso8859-1,但写了utf-8所以不要再转
		//path = new String(path.getBytes("iso-8859-1"), "UTF-8");
		String ext=path.substring(path.lastIndexOf("."));
		System.out.print("路径"+path);
		response.setHeader("Content-Disposition", "attachment; filename=20170723.jpg;");
		String strUrl = path;
		URLConnection uc = null;
		System.out.println(strUrl);
		try {
			URL url = new URL(strUrl);
			uc = url.openConnection();
			uc.setRequestProperty("User-Agent", "Mozilla/4.0 (compatible; MSIE 5.0; Windows XP; DigExt)");
			//uc.setReadTimeout(30000);
			//获取图片长度  
			System.out.println("Content-Length:     "+uc.getContentLength()); 
			//获取文件头信息
			System.out.println("Header"+uc.getHeaderFields().toString());         
			//	if (uc == null)
			//	 return 0;
			InputStream ins = uc.getInputStream();
			byte[] str_b = new byte[1024];
			int byteRead = 0;
			String[] images = strUrl.split("/");
			String imagename = images[images.length - 1];
			OutputStream fos = response.getOutputStream();
			while ((byteRead = ins.read(str_b)) > 0) {
				fos.write(str_b, 0, byteRead);
			}
			;
			fos.flush();
			fos.close();
		} catch (Exception e) {
			e.printStackTrace();
			//log.error("获取网页内容出错");
		} finally {
			uc = null;
		}
	%>