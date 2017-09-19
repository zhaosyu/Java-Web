/**
 * 
 */
$(function(){
	var v=0;

	$("#transform_left").click(function(){
		v=v-1;
		$("#uploadImg,#addimg").css("-webkit-transform","rotate("+v*45+"deg)");
	})
	$("#transform_right").click(function(){
		v=v+1;
		$("#uploadImg,#addimg").css("-webkit-transform","rotate("+v*45+"deg)");
	})
	$("#addimg").click(function(){
		$("#file").click();
		$("#file").on("change",function(){
			var objUrl=getObjectURL(this.files[0]);
			if(objUrl){
				$("#uploadImg,#addimg").attr("src",objUrl);
			}
			$("#transform_left,#transform_right").css("display","block");
		})
	})
	$("#file").click(function(){
		$("#file").on("change",function(){
			var objUrl=getObjectURL(this.files[0]);
			if(objUrl){
				$("#uploadImg,#addimg").attr("src",objUrl);
			}
			$("#transform_left,#transform_right").css("display","block");
		});
	});	
	if($("#addimg").attr("src")!="img/add.bmp"){
		$("#transform_left,#transform_right").css("display","block");
	}
})
function check_form() {
	if ($("input[name=title]:text").val().replace(/\s+/g, "") == "") {
		alert("照片标题不能为空！");
		flash("input[name=title]:text", 8, 10, 100);
		$("input[name=title]:text").focus();
		return false;
	} else if ($("#type").val() == "") {
		alert("请先选择一个类别！");
		flash("#type", 8, 10, 100);
		$("#type").focus();
		return false;
	}else if($("textarea[name=description]").val().replace(/\s+/g, "") == ""){
		alert("描述不能为空！");
		flash("textarea[name=description]", 8, 10, 100);
		$("textarea[name=description]").focus();
		return false;
	}else{
		return true;
	}
}

function flash(obj, time, wh, fx) {
	$(function() {
		var $panel = $(obj);
		var offset = $panel.offset() - $panel.width();
		var x = offset.left;
		var y = offset.top;
		for (var i = 1; i <= time; i++) {
			if (i % 2 == 0) {
				$panel.animate({
					left : '+' + wh + 'px'
				}, fx);
			} else {
				$panel.animate({
					left : '-' + wh + 'px'
				}, fx);
			}

		}
		$panel.animate({
			left : 0
		}, fx);
		$panel.offset({
			top : y,
			left : x
		});

	});
}
function getObjectURL(file){
	var url=null;
	if(window.createObjectURL!=undefined){
		url=window.createObjectURL(file);
	}
	else if(window.URL!=undefined){
		url=window.URL.createObjectURL(file);
	}
	else if(window.webkitURL!=undefined){
		url=window.webkitURL.createObjectURL(file);
	}
	return url;
}