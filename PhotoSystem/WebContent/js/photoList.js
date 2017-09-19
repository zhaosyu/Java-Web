$(function() {
	$(".gallery .ss").not("#delete").hover(function() {
		var delclass = $(".ss").index(this);
		$("#delete").css({
			"display" : "block",
			"cursor" : "pointer",
			"top" : $(this).offset().top + 10,
			"left" : $(this).offset().left + 10,
			"index" : "1000"
		});
		$("#delete").attr("class", delclass);
	});

	$(".gallery").mouseleave(
			function(event) {
				if (typeof (event) != "undefined"
						&& typeof (event.relatedTarget) != "undefined"
						&& event.relatedTarget != null) {
					if (typeof (event.relatedTarget.nodeName) != "undefined") {
						if (event.relatedTarget.id != "delete") {
							$("#delete").fadeOut();
						}
					}
				}
			});

	$("#delete").click(function() {

		if (confirm("是否删除该照片？此操作不可恢复！")) {
			var index = $("#delete").attr("class");

			$.post("photoList.jsp", {
				action : "del",
				id : $(".imgid:eq(" + index + ")").val(),
				pageNum:GetQueryString("pageNum"),
				pClass:$.cookie('pClass')
			}, function(data) {
				if(data.trim("")!="false" && data!=null)
				{
					//alert(data);
					$(".container").remove();
					$("#right_side").append(data);
				}else{
					alert("删除数据出现错误");
				}
				$("#delete").fadeOut();
			},"html");
			//$(".ss:eq(" + index + ")").remove();
		}
	});
	$(".ss ul").hover(function() {
		$(this).children(":last").show();
		$(this).children().css({
			"background-color" : "#fac400",
			"color" : "white"
		});
	}, function() {
		$(this).children().css({
			"background-color" : "",
			"color" : "black"
		});
		$(this).children(":last").hide();
	});
	$("#selectAll").change(function() {
		var checkedNum = $("input[name=include]:checked").length;
		var total = $("input[name=include]").length;
		if (checkedNum < total) {
			$("input[name=include]").attr("checked", false);
		}
		// 全部反选
		$("input[name=include]").each(function() {
			this.checked = !this.checked
		});
	});
	$("input[name=include]").live("change", function() {
		var checkedNum = $("input[name=include]:checked").length;
		var total = $("input[name=include]").length;
		if (checkedNum < total) {
			$("#selectAll").attr("checked", false);
		} else {
			$("#selectAll").attr("checked", true);
		}
	});
	$("#deleteMany").click(function() {
		if (checkedNum = $("input[name=include]:checked").length > 0){
			if (confirm("是否删除这些照片？此操作不可恢复！")) {
				var arr=new Array();
				$("input[name=include]:checked").each(function(){
					var temp=$(this).attr("class").split(" ");
					arr.push(temp[1]);
//					$(this).parents(".ss").remove();
				});

				var ids=arr.join(",");
				
				$.post("photoList.jsp", {
					action : "delMany",
					imgids : ids,
					pageNum:GetQueryString("pageNum"),
					pClass:$.cookie('pClass')
				}, function(data) {
					if(data.trim("")!="false" && data!=null)
					{
						$(".container").remove();
						$("#right_side").append(data);
						$("#delete").fadeOut();
						
						if($("#selectAll").is(":checked"))
							$(".gallery").text("没有照片了，赶紧去添加吧~").css({"color":"red","width":"885px"});
					}else{
						alert("删除数据出现错误");
					}
				},"html");
			}
		}else{
			alert("你还没有选择要删除照片！");
		}
	});
	$(".gallery .photoListCon").click(function(){
		
		$.post("add.jsp", {
			action:"detail",
			id : $(this).attr("class").split(" ")[1] 
		}, function(data) {
			if(data!=null)
			{
				$(".container").remove();
				$("#right_side").html(data);
			}else{
				alert("加载页面出现错误");
			}
		},
		"html");
	});
	$(".gallery .photoListEdit").click(function(){

		$.post("add.jsp", {
			action:"update",
			id : $(this).prev().attr("class").split(" ")[1] 
		}, function(data) {
			if(data!=null)
			{
				$(".container").remove();
				$("#right_side").html(data);
			}else{
				alert("加载页面出现错误");
			}
		},
		"html");
	});
	$(".photoListDownLoad").click(function(){
		path=$(this).parent().prev().find("a").attr("href");
		SaveToLocal(path);
	});
});

function SaveToLocal(path)
{
    var src = "download.jsp?path=http://localhost:8080/PhotoSystem/"+path;
    document.getElementById("ModifyCameraForm").src = src;        
}