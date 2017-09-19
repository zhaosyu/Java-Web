package com.photo.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import entity.User;

public class insertLogin {

	public static User Insertlogin(String jdbcConfigPath, String loginUsername, String loginPassword) {
		
		User user = null;

		Properties prop = new Properties();
		Connection conn1 = null;Connection conn2 = null;
		PreparedStatement stmt1 = null;
		PreparedStatement stmt2 = null;
		ResultSet rs = null;
		ResultSet rs2 = null;
		try {
        
			prop.load(new FileInputStream(jdbcConfigPath + "\\jdbc.properties"));
			
			String driver = prop.getProperty("driver");
			String host = prop.getProperty("host");
			String port = prop.getProperty("port");
			String database = prop.getProperty("database");
			String databaseUsername = prop.getProperty("username");
			String databasePassword = prop.getProperty("password");
			
			Class.forName(driver);
			String url = "jdbc:mysql://" + host + ":" + port + "/" + database 
					+ "?useUnicode=true&characterEncoding=utf-8";
		
			conn1 = DriverManager.getConnection(url, databaseUsername, databasePassword);
			conn2 = DriverManager.getConnection(url, databaseUsername, databasePassword);
			
//			String sql = "select count(*) ucount from user where name='" 
//					+ loginName + "' and password='" 
//					+ userPassword + "'";
			
			String sql1 = "select * from user where name=?";
			stmt1 = conn1.prepareStatement(sql1);
			stmt1.setString(1, loginUsername);
			rs = stmt1.executeQuery();
			
//			System.out.println("查询前");
			
			sql1 = "select count(*) from user";
			stmt2 = conn2.prepareStatement(sql1);
			rs2 = stmt2.executeQuery();
			rs2.next();
			int id = rs2.getInt("count(*)");id=id+1;//获取新用户该赋予的id值
			
			
			if(!rs.next()) {
				user = new User(id, loginUsername, loginUsername);
				 sql1 = "INSERT INTO user(id, name, password, display_name) values('"+id+"','"+loginUsername+"','"+loginPassword+"','"+loginUsername+"')";
				stmt2 = conn2.prepareStatement(sql1);
				stmt2.executeUpdate();
			}
	    
		 }
		catch(ClassNotFoundException e) {
			System.err.println("错误：数据库驱动未找到！");
		}
		catch(SQLException e) {
			System.out.println("错误:数据库访问异常！" + e.getMessage());
		}catch(IOException e) {
			System.out.println("错误：读取配置文件错误！");
		} finally{
			DBUtil.close(conn1);
			DBUtil.close(stmt1);
			DBUtil.close(rs);
		}
		return user;
    }
}
	

	

