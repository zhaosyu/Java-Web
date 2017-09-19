package entity;

public class User {
	private int id;
	private String loginName;
	private String displayName;
	
	public User(int id, String loginName, String displayName) {
		this.id = id;
		this.loginName = loginName;
		this.displayName = displayName;
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

	public String getDisplayName() {
		return displayName;
	}

	public void setDisplayName(String displayName) {
		this.displayName = displayName;
	}

}
