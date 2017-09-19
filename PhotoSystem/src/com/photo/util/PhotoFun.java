package com.photo.util;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Properties;

import entity.Photo;

public class PhotoFun {
	static Properties prop=new Properties();
	static Connection con=null;
	static PreparedStatement stmt=null;
	static PreparedStatement stmt2=null;
	static ResultSet rs=null;

	public static Photo getPhotoById(int id,String path){
		try {
			prop.load(new FileInputStream(path + "/jdbc.properties"));
			
			String driver=prop.getProperty("driver");
			String host=prop.getProperty("host");
			String port=prop.getProperty("port");
			String database=prop.getProperty("database");
			String username=prop.getProperty("username");
			String password=prop.getProperty("password");

			Class.forName(driver);//加载驱动
			String url="jdbc:mysql://"+host+":"+port+"/"+database+"?userUnicode=true&characterEncoding=utf-8";
			con=DriverManager.getConnection(url,username,password);
			String querySql="select class,title,url,descb,pTime from picture where id=?";
			stmt=con.prepareStatement(querySql);
			stmt.setInt(1, id);
			rs=stmt.executeQuery();
			
			if (rs.next()) {
				return new Photo(id,rs.getString("class"),rs.getString("title"),rs.getString("url"),rs.getString("descb"),rs.getString("pTime"));
			}

		}catch (ClassNotFoundException e) {
			System.out.println("错误：数据库驱动未找到");
		}catch (SQLException e) {
			System.out.println("数据库访问异常："+e.getMessage());
		} catch (FileNotFoundException e) {
			System.out.println("没有找到配置文件");
		} catch (IOException e) {
			System.out.println("读取配置文件错误");
		}finally {
			//关闭时要倒着写
			DBUtil.close(rs);
			DBUtil.close(stmt2);
			DBUtil.close(stmt);
			DBUtil.close(con);
		}
		return null;
	}
	
	///
	///删除图片
	///
	public static boolean deleteImg(String action,String id,String path){
		try {
			prop.load(new FileInputStream(path + "/jdbc.properties"));
			
			String driver=prop.getProperty("driver");
			String host=prop.getProperty("host");
			String port=prop.getProperty("port");
			String database=prop.getProperty("database");
			String username=prop.getProperty("username");
			String password=prop.getProperty("password");
			Class.forName(driver);//加载驱动
			String url="jdbc:mysql://"+host+":"+port+"/"+database+"?userUnicode=true&characterEncoding=utf-8";
			con=DriverManager.getConnection(url,username,password);
			String querySql="";
			if(action.equals("del") &&id!=null){
				//删除单张图片
				querySql="delete from picture where id=?";
				stmt=con.prepareStatement(querySql);
				//stmt.setInt(1,Integer.parseInt(request.getParameter("id")));
				stmt.setString(1, id);
				int result=stmt.executeUpdate();
				if(result<=0){
					return false;
				}else{
						//out.print("删除多条数据成功！");
						return true;
					}
			}else if(action.equals("delMany") && id!=null){
				//删除多张
				String[] imgids=id.split(",");
				querySql="delete from picture where ";
				for(int i=0;i<imgids.length;i++){
					querySql+="id=? or ";
				}
				querySql=querySql.substring(0, querySql.length()-4);
				//out.print(querySql+"id"+imgids[1]+":length"+imgids.length);
				stmt=con.prepareStatement(querySql);
				for(int i=0;i<imgids.length;i++){
					stmt.setString(i+1, imgids[i]);
				}
				int result=stmt.executeUpdate();
				if(result<=0){
					return false;
				}else{
					return true;
				}
			}else{
//				out.print(request.getParameter("id"));
				//response.sendRedirect("login.jsp");
				return false;
			}
		}catch (ClassNotFoundException e) {
			return false;
		}catch (SQLException e) {
			//	out.println("数据库访问异常："+e.getMessage());
			return false;
		} catch (FileNotFoundException e) {
			//out.println("没有找到配置文件");
			return false;
		} catch (IOException e) {
				//out.println("读取配置文件错误");
			return false;
		}finally {
			//关闭时要倒着写
			DBUtil.close(stmt);
			DBUtil.close(con);
		}
	}
	
	//D:\\Workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\PhotoSystem\\WEB-INF
	public static ArrayList<Photo> SearchPagedPhotoByTitle(String str,String path, int pageNo, int pageSize,String pClass,int ownerid){
		ArrayList<Photo> list = new ArrayList<>();
		try {
			prop.load(new FileInputStream(path + "/jdbc.properties"));
			
			String driver=prop.getProperty("driver");
			String host=prop.getProperty("host");
			String port=prop.getProperty("port");
			String database=prop.getProperty("database");
			String username=prop.getProperty("username");
			String password=prop.getProperty("password");
			Class.forName(driver);//加载驱动
			String url="jdbc:mysql://"+host+":"+port+"/"+database+"?userUnicode=true&characterEncoding=utf-8";
			con=DriverManager.getConnection(url,username,password);
			String querySql="";
			int index = (pageNo - 1) * pageSize;
			if(pClass.equals("全部")){
				querySql="select * from picture where title like ? and ownerid=? order by pTime desc limit ?,?";//////////////
				stmt=con.prepareStatement(querySql);
				stmt.setString(1, "%"+str+"%");
				stmt.setInt(2, ownerid);
				stmt.setInt(3, index);
				stmt.setInt(4, pageSize);
			}else{
				querySql="select * from picture where title like ? and class=? and ownerid=? order by pTime desc limit ?,?";
				stmt=con.prepareStatement(querySql);
				stmt.setString(1, "%"+str+"%");
				stmt.setString(2, pClass);
				stmt.setInt(3, ownerid);
				stmt.setInt(4, index);
				stmt.setInt(5, pageSize);
			}
			
			rs=stmt.executeQuery();
			while (rs.next()) {
				int id = rs.getInt("id");
				String type = rs.getString("class");
				String title = rs.getString("title");
				String url1 = rs.getString("url");
				String describe = rs.getString("descb");
				String pTime = rs.getString("pTime");
				Photo photos = new Photo(id, type, title, url1, describe,pTime);
				list.add(photos);
			}

		}catch (ClassNotFoundException e) {
			System.out.println("错误：数据库驱动未找到");
		}catch (SQLException e) {
			System.out.println("数据库访问异常："+e.getMessage());
		} catch (FileNotFoundException e) {
			System.out.println("没有找到配置文件");
		} catch (IOException e) {
			System.out.println("读取配置文件错误");
		}finally {
			//关闭时要倒着写
			DBUtil.close(rs);
			DBUtil.close(stmt2);
			DBUtil.close(stmt);
			DBUtil.close(con);
		}
		return list;
	}
	public static boolean uploadPhoto(String type,String title,String url1,String describe,String path,int ownerid){
		try {
			prop.load(new FileInputStream(path + "/jdbc.properties"));
			
			String driver=prop.getProperty("driver");
			String host=prop.getProperty("host");
			String port=prop.getProperty("port");
			String database=prop.getProperty("database");
			String username=prop.getProperty("username");
			String password=prop.getProperty("password");

			Class.forName(driver);//加载驱动
			String url="jdbc:mysql://"+host+":"+port+"/"+database+"?userUnicode=true&characterEncoding=utf-8";
			con=DriverManager.getConnection(url,username,password);
			String querySql="insert into picture(class,title,url,descb,ownerid) values(?,?,?,?,?) ";
			stmt=con.prepareStatement(querySql);
			stmt.setString(1, type);
			stmt.setString(2, title);
			stmt.setString(3, url1);
			stmt.setString(4, describe);
			stmt.setInt(5, ownerid);
			int result=stmt.executeUpdate();
			
			if (result>0) {
				return true;
			}

		}catch (ClassNotFoundException e) {
			System.out.println("错误：数据库驱动未找到");
		}catch (SQLException e) {
			System.out.println("数据库访问异常："+e.getMessage());
		} catch (FileNotFoundException e) {
			System.out.println("没有找到配置文件");
		} catch (IOException e) {
			System.out.println("读取配置文件错误");
		}finally {
			//关闭时要倒着写
			DBUtil.close(rs);
			DBUtil.close(stmt2);
			DBUtil.close(stmt);
			DBUtil.close(con);
		}
		return false;
	}
	public static boolean updatePhoto(int id,String type,String title,String url1,String describe,String path){
		try {
			prop.load(new FileInputStream(path + "/jdbc.properties"));
			
			String driver=prop.getProperty("driver");
			String host=prop.getProperty("host");
			String port=prop.getProperty("port");
			String database=prop.getProperty("database");
			String username=prop.getProperty("username");
			String password=prop.getProperty("password");

			Class.forName(driver);//加载驱动
			String url="jdbc:mysql://"+host+":"+port+"/"+database+"?userUnicode=true&characterEncoding=utf-8";
			con=DriverManager.getConnection(url,username,password);
			if(!url1.equals("")){
				String querySql="update picture set class=?,title=?,url=?,descb=? where id=?";
				stmt=con.prepareStatement(querySql);
				stmt.setString(1, type);
				stmt.setString(2, title);
				stmt.setString(3, url1);
				stmt.setString(4, describe);
				stmt.setInt(5, id);				
			}else{
				String querySql="update picture set class=?,title=?,descb=? where id=?";
				stmt=con.prepareStatement(querySql);
				stmt.setString(1, type);
				stmt.setString(2, title);
				stmt.setString(3, describe);
				stmt.setInt(4, id);	
			}

			int result=stmt.executeUpdate();
			
			if (result>0) {
				return true;
			}

		}catch (ClassNotFoundException e) {
			System.out.println("错误：数据库驱动未找到");
		}catch (SQLException e) {
			System.out.println("数据库访问异常："+e.getMessage());
		} catch (FileNotFoundException e) {
			System.out.println("没有找到配置文件");
		} catch (IOException e) {
			System.out.println("读取配置文件错误");
		}finally {
			//关闭时要倒着写
			DBUtil.close(rs);
			DBUtil.close(stmt2);
			DBUtil.close(stmt);
			DBUtil.close(con);
		}
		return false;
	}
//	public static void main(String[] args) {
//		boolean p=uploadPhoto("其他","好踢踢","uploadPhoto/Lighthouse.jpg","ashujda","D:\\Workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\PhotoSystem\\WEB-INF",3);
//		System.out.println(p);
//	}
}
