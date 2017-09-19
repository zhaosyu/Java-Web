package entity;

public class Photo {

	private int id;
	private String type;
	private String title;
	private String url;
	private String describe;
	private String time;
	
	public int getId() {
		return id;
	}

	public String getTime() {
		return time;
	}

	public void setTime(String time) {
		this.time = time;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getDescribe() {
		return describe;
	}

	public void setDescribe(String describe) {
		this.describe = describe;
	}

	public Photo(int id,String type,String title,String url,String describe,String time) {
		// TODO Auto-generated constructor stub
		this.id=id;
		this.type=type;
		this.title=title;
		this.url=url;
		this.describe=describe;
		this.time=time;
	}
}
