<%@ page language="java" contentType="image/jpeg"
    pageEncoding="UTF-8" 
    import="java.awt.image.*,java.io.*,javax.imageio.*,captcha.CaptchaGenerator"%><%
    out.clear();
    
    response.setHeader("Pragma", "No-cache");
	response.setHeader("Cache-Control", "no-cache");
	response.setDateHeader("Expires", 0);

	CaptchaGenerator generator = new CaptchaGenerator(20, 60);
	generator.generate();
	String value = generator.getValue();
	BufferedImage img = generator.getImage();
	
	session.setAttribute("captcha", value);
	
	OutputStream oStream = response.getOutputStream();
	ImageIO.write(img, "JPEG", oStream);
%>