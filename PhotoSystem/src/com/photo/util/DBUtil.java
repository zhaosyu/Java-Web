package com.photo.util;

public class DBUtil {

	public static void close(AutoCloseable closeable) {
		// TODO Auto-generated method stub
		if (closeable != null) {
			try {
				closeable.close();
			} catch (Exception e) {
				System.out.println("关闭错误："+e.getMessage());;
			}
		}
	}
}
