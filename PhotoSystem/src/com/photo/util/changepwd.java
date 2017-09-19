package com.photo.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import entity.User4;

public class changepwd {

	public static User4 ChangePwd(String jdbcConfigPath, String Username, String oldPassword, String newPassword) {
		User4 user4 = null;

		Properties prop = new Properties();
		Connection conn = null;
		Connection conn2 = null;
		PreparedStatement stmt = null;
		PreparedStatement stmt2 = null;
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
			conn2 = DriverManager.getConnection(url, databaseUsername, databasePassword);
			
//			String sql = "select count(*) ucount from user where name='" 
//					+ loginName + "' and password='" 
//					+ userPassword + "'";
			
			String sql = "select * from user where name=? and password=?";
			stmt = conn.prepareStatement(sql);
			
			stmt.setString(1, Username);
			stmt.setString(2, oldPassword);
			
			rs = stmt.executeQuery();
			if(rs.next()) {
				int id = rs.getInt("id");
				sql = "update user set password='" + newPassword + "' where id="+ id ;
				stmt2 = conn2.prepareStatement(sql);
				stmt2.executeUpdate();
				
				String loginName = rs.getString("name");
				
				user4 = new User4(id, loginName, oldPassword,newPassword);
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
		
		return user4;
	}
}
