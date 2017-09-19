package entity;

public class User4 {
	private int id;
	private String loginName;
	private String oldpassword;
	private String newpassword;
	
	
	public User4(int id, String loginName, String oldpassword, String newpassword) {
		this.id = id;
		this.loginName = loginName;
		this.oldpassword = oldpassword;
		this.newpassword = newpassword;
		
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getLoginName() {
		return loginName;
	}

	public void setLoginName(String loginName) {
		this.loginName = loginName;
	}

	
	public String getOldPassword() {
		return oldpassword;
	}
	public void setOldPassword(String oldpassword) {
		this.oldpassword = oldpassword;
	}
	
	public String getNewPassword() {
		return newpassword;
	}
	public void setNewPassword(String newpassword) {
		this.newpassword = newpassword;
	}
	


}
