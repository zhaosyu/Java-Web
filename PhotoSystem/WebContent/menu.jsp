<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!-- 动态菜单CSS -->
<link rel="stylesheet" type="text/css" href="css/menu.css">
<!-- jquery引入 -->
<!-- <script src="js/jquery-1.8.3.min.js"></script> -->
<!-- <script src="js/jquery.cookie.js" type="text/javascript"></script> -->
<!-- 动态菜单JS -->
<!-- <script type="text/javascript" src="js/menu.js"></script> -->

<div id="left_side">
	<div class="leftMenu">
		<div class="topMenu">
			<img class="banshi" src="img/banshidating.png" />
			<p class="menuTitle">照片菜单</p>
			<img class="changeMenu" src="img/shouqicaidan.png"
				onClick="hidMenu()">
		</div>
		<div class="menu_list">
			<ul>
				<li class="" id="menuFirst">
					<div class="div1">
						<p class="zcd" id="zcd0">全部</p>
						<p class="zcd" id="zcd1">风景</p>
						<p class="zcd" id="zcd2">人物</p>
						<p class="zcd" id="zcd3">地点</p>
						<p class="zcd" id="zcd5">事物</p>
						<p class="zcd" id="zcd6">生活</p>
						<p class="zcd" id="zcd7">工作</p>
						<p class="zcd" id="zcd8">其他</p>
					</div>
				</li>
				<li class="">
					<p class="fuMenu">管理</p> <img class="xiala" src="img/xiala.png" />
					<div class="div1">
						<p class="zcd" id="menuAddImg">添加照片</p>
						<p class="zcd" id="zcd10">好友照片</p>
					</div>
				</li>
			</ul>
		</div>
	</div>
</div>
