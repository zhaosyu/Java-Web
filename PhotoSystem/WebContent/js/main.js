	$("#menu1").css("background-color","#333344").css("color","white");
	$(".menu").click(function(){
		$(this).css("background-color","#333344").css("color","white");
	});
	
	$(".menu").bind({
		mouseover:function(){
			if($(this).css('background-color') != 'rgb(51, 51, 68)'){
				$(this).css("background-color","#f5f5f5");
			}
		},
		mouseout:function(){
			if($(this).css('background-color') != 'rgb(51, 51, 68)'){
				$(this).css("background-color","#FFFFFF");
			}
		}
		
	});
	
	$(".menu").click(function(){
		$("#left ul li a").css("background-color","#FFFFFF").css("color","black");
		$(this).css("background-color","#333344").css("color","white");
	})
	
	
	
	$("#btn").hide();
	$("#searchbar [name=searchbar]").keyup(function(){
		if($(this).val() == "" ){
			$("#btn").hide();
		}
		else{
			$("#btn").show();
		}
	})