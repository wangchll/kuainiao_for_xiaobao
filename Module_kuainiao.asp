<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
		<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
		<link rel="shortcut icon" href="images/favicon.png"/>
		<link rel="icon" href="images/favicon.png"/>
		<title>软件中心 - ShadowVPN</title>
		<link rel="stylesheet" type="text/css" href="index_style.css"/>
		<link rel="stylesheet" type="text/css" href="form_style.css"/>
		<link rel="stylesheet" type="text/css" href="usp_style.css"/>
		<link rel="stylesheet" type="text/css" href="ParentalControl.css">
		<link rel="stylesheet" type="text/css" href="css/icon.css">
		<link rel="stylesheet" type="text/css" href="css/element.css">
		<script type="text/javascript" src="/state.js"></script>
		<script type="text/javascript" src="/popup.js"></script>
		<script type="text/javascript" src="/help.js"></script>
		<script type="text/javascript" src="/validator.js"></script>
		<script type="text/javascript" src="/js/jquery.js"></script>
		<script type="text/javascript" src="/general.js"></script>
		<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
        <script type="text/javascript" src="http://i.xunlei.com/login/lib/rsa.js"></script>
        <script type="text/javascript" src="http://i.xunlei.com/login/lib/md5.js"></script>
        <script type="text/javascript">
        var kn = '00D6F1CFBF4D9F70710527E1B1911635460B1FF9AB7C202294D04A6F135A906E90E2398123C234340A3CEA0E5EFDCB4BCF7C613A5A52B96F59871D8AB9D240ABD4481CCFD758EC3F2FDD54A1D4D56BFFD5C4A95810A8CA25E87FDC752EFA047DF4710C7D67CA025A2DC3EA59B09A9F2E3A41D4A7EFBB31C738B35FFAAA5C6F4E6F';
        var ke = '010001';

        var rsa = new RSAKey();

        rsa.setPublic(kn, ke);
        //var encrypted_pwd = rsa.encrypt(md5(pwd));
        //console.log(md5(pwd));
        //console.log(encrypted_pwd.toUpperCase());
        //res.json({'encrypted_pwd':encrypted_pwd})
		function onSubmitCtrl(o, s) {
			document.form.action_mode.value = s;
			//开始赋值
			//$("#kuainiao_config_uname").val("wangchll");
			var pwd = $("#kuainiao_config_old_pwd").val();
			var encrypted_pwd = rsa.encrypt(md5(pwd));
			$("#kuainiao_config_pwd").val(encrypted_pwd.toUpperCase());
			showLoading(5);
			document.form.submit();
		}
        </script>
    </head>
    <body>
		<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
		<form method="post" name="form" action="/applydb.cgi?p=kuainiao_" target="hidden_frame">
			<input type="hidden" name="current_page" value="Module_kuainiao.asp"/>
			<input type="hidden" name="next_page" value="Module_kuainiao.asp"/>
			<input type="hidden" name="group_id" value=""/>
			<input type="hidden" name="modified" value="0"/>
			<input type="hidden" name="action_mode" value=""/>
			<input type="hidden" name="action_script" value=""/>
			<input type="hidden" name="action_wait" value="5"/>
			<input type="hidden" name="first_time" value=""/>
			<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
			<input type="hidden" name="SystemCmd" onkeydown="onSubmitCtrl(this, ' Refresh ')" value="config-kuainiao.sh"/>
			<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
			<input type="text" id="kuainiao_config_uname" name="kuainiao_config_uname" value='<% dbus_get_def("kuainiao_config_uname", ""); %>'/>
			<input type="text" id="kuainiao_config_old_pwd" name="kuainiao_config_old_pwd" value='<% dbus_get_def("kuainiao_config_old_pwd", ""); %>'/>
			<input type="hidden" id="kuainiao_config_pwd" name="kuainiao_config_pwd" value='<% dbus_get_def("kuainiao_config_pwd", ""); %>'/>
			<input type="text" id="kuainiao_warning" name="kuainiao_warning" value='<% dbus_get_def("kuainiao_warning", ""); %>'/>
			<button id="cmdBtn" class="" onclick="onSubmitCtrl(this, ' Refresh ')">提交</button>
		</form>
    </body>
</html>
