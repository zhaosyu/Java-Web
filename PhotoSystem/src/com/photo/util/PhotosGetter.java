package com.photo.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import entity.Photo;

public class PhotosGetter {

	public static int getPhotosCount(String jdbcConfigPath, String pClass,String key,int ownerid) {
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
			String sql = "";
			if (pClass.equals("全部")) {
				sql = "select count(*) ucount from picture where title like ? and ownerid=?";
				stmt = conn.prepareStatement(sql);
				stmt.setString(1, "%"+key+"%");
				stmt.setInt(2, ownerid);
			} else {
				sql = "select count(*) ucount from picture where class=? and title like ? and ownerid=?";
				stmt = conn.prepareStatement(sql);
				stmt.setString(1, pClass);
				stmt.setString(2, "%"+key+"%");
				stmt.setInt(3, ownerid);
			}

			rs = stmt.executeQuery();
			rs.next();
			int count = rs.getInt("ucount");
			return count;

		} catch (ClassNotFoundException e) {
			System.err.println("错误：数据库驱动未找到！");
		} catch (SQLException e) {
			System.out.println("错误:数据库访问异常！" + e.getMessage());
		} catch (IOException e) {
			System.out.println("错误：读取配置文件错误！");
		} finally {
			DBUtil.close(conn);
			DBUtil.close(stmt);
			DBUtil.close(rs);
		}

		return 0;
	}

	public static ArrayList<Photo> getPagedPhotosList(String jdbcConfigPath, int pageNo, int pageSize, String pClass,int ownerid) {
		ArrayList<Photo> list = new ArrayList<>();

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

			// String sql = "select count(*) ucount from user where name='"
			// + loginName + "' and password='"
			// + userPassword + "'";
			String sql = "";
			if (pClass.equals("全部"))
				sql = "select id,class, title, url,descb,pTime from picture where ownerid=? order by pTime desc limit ?,?";
			else
				sql = "select id,class, title, url,descb,pTime from picture where class=? and ownerid=? order by pTime desc limit ?,?";
			int index = (pageNo - 1) * pageSize;

			stmt = conn.prepareStatement(sql);

			if (pClass.equals("全部")) {
				stmt.setInt(1, ownerid);
				stmt.setInt(2, index);
				stmt.setInt(3, pageSize);
			} else {
				stmt.setString(1, pClass);
				stmt.setInt(2, ownerid);
				stmt.setInt(3, index);
				stmt.setInt(4, pageSize);
			}

			rs = stmt.executeQuery();
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

		} catch (ClassNotFoundException e) {
			System.err.println("错误：数据库驱动未找到！");
		} catch (SQLException e) {
			System.out.println("错误:数据库访问异常！" + e.getMessage());
		} catch (IOException e) {
			System.out.println("错误：读取配置文件错误！");
		} finally {
			DBUtil.close(conn);
			DBUtil.close(stmt);
			DBUtil.close(rs);
		}

		return list;
	}
	public static void main(String[] args) {
//		ArrayList<Photo> p=getPagedPhotosList("D:\\Workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\PhotoSystem\\WEB-INF", 1, 6, "风景",4);
//		System.out.println(p.size());
//		ArrayList<Photo> p=getPagedPhotosList("D:\\Workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\PhotoSystem\\WEB-INF", 1, 6, "风景",4);
//		System.out.println(p.size());
//		int p=getPhotosCount("D:\\Workspace\\.metadata\\.plugins\\org.eclipse.wst.server.core\\tmp0\\wtpwebapps\\PhotoSystem\\WEB-INF","风景","",4);
//		System.out.println(p);
	}
}
