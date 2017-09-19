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

public class LoginChecker {

	public static User checkLogin(String jdbcConfigPath, String loginUsername, String loginPassword) {
		User user = null;

		Properties prop = new Properties();
		Connection conn = null;
		PreparedStatement stmt = null;
		ResultSet rs = null;
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
			
			conn = DriverManager.getConnection(url, databaseUsername, databasePassword);
			
//			String sql = "select count(*) ucount from user where name='" 
//					+ loginName + "' and password='" 
//					+ userPassword + "'";
			
			String sql = "select * from user where name=? and password=?";
			stmt = conn.prepareStatement(sql);
			
			stmt.setString(1, loginUsername);
			stmt.setString(2, loginPassword);
			
			rs = stmt.executeQuery();
			if(rs.next()) {
				int id = rs.getInt("id");
				String loginName = rs.getString("name");
				String displayName = rs.getString("display_name");
				
				user = new User(id, loginName, displayName);
			}
			
		}catch(ClassNotFoundException e) {
			System.err.println("错误：数据库驱动未找到！");
		}catch(SQLException e) {
			System.out.println("错误:数据库访问异常！" + e.getMessage());
		} catch(IOException e) {
			System.out.println("错误：读取配置文件错误！");
		} finally{
			DBUtil.close(conn);
			DBUtil.close(stmt);
			DBUtil.close(rs);
		}	
		
		return user;
	}
}
