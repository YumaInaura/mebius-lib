
#-----------------------------------------------------------
# Not Found �G���[�y�[�W - strict
#-----------------------------------------------------------
sub main_errorpage{

# �錾
my($google_box);
our($css_text,$submode2,$headflag,$status_flag,$alocal_mode,$body_javascript,$google_box,$google_oe,$referer);
our($alocal_mode);


# CSS��`
$css_text .= qq(
.message_box{padding:30px 5%;width:70%;margin:0em auto 1em auto;text-align:center;border:1px #000000 solid;}
strong.status{color:#f00;font-size:110%;}
.vertical{vertical-align:middle;}
.back_links{font-size:90%;word-spacing:0.2em;}
.index_find{margin:1em 0em;}
.index_find2{margin:1em 4em;text-align:left;background:#dee;padding:1em;font-size:90%;font-weight:normal;}
b{color:#000;font-weight:normal;}
);

	# ���[�J��
	if($alocal_mode){
		$referer = "http://localhost/_test/1281.html";
	}


# Body Javascript ��`
$body_javascript = qq( onload="document.google.q.focus()");

# Google �����{�b�N�X
$google_box = qq(
<div class="index_find2">
<script type="text/javascript">
  var GOOG_FIXURL_LANG = 'ja';
  var GOOG_FIXURL_SITE = 'http://$server_domain/'
</script>
<script type="text/javascript"
  src="http://linkhelp.clients.google.com/tbproxy/lh/wm/fixurl.js">
</script>
</div>
);

# Google�����{�b�N�X
$google_box = qq(
<form method="get" action="http://www.google.co.jp/search" class="index_find" name="google"> 
<div>
<a href="http://www.google.co.jp/" rel="nofollow">
<img src="http://www.google.co.jp/logos/Logo_25wht.gif" class="google_img vertical" alt="Google"></a>
<input type="text" name="q" size="41" maxlength="255" value="" class="vertical">
<input type="submit" name="btnG" value="���r�E�X�����O������" class="vertical">
<input type="hidden" name="sitesearch" value="mb2.jp">
<input type="hidden" name="ie" value="Shift_JIS">
$google_oe
<input type="hidden" name="hl" value="ja">
<input type="hidden" name="domains" value="mb2.jp">
</div>
</form>
);

	# ���[�h�U�蕪��
	if($submode2 eq "404"){ &main_errorpage_view("","404",$google_box); }
	elsif($submode2 eq "403"){ &main_errorpage_view("","403",$google_box); }
	elsif($submode2 eq "401"){ &main_errorpage_view("","401",$google_box); }
	else{ &error("�ق�Ƃ� NotFound"); }

exit;

}

#-----------------------------------------------------------
# �e��G���[ - strict
#-----------------------------------------------------------
sub main_errorpage_view{

# �錾
my($basic_init) = Mebius::basic_init();
my($type,$status,$google_box) = @_;
my($message);
our($back_links,$sub_title,$referer,$door_url,$int_dir,$requri,$selfurl);

# ���_�C���N�g�~�X������ꍇ�A�ʘg�ŋL�^
if($requri =~ /%23/){ Mebius::AccessLog(undef,"REDIRECT-MISSED","$status	Dead-link http://$server_domain$requri	Referer $referer	$date"); }

# �����N�؂�y�[�W���L�^
Mebius::AccessLog(undef,"$status","$status	Dead-link http://$server_domain$requri	Referer $referer	$date");


# ���������N�؂�C��
if($status eq "404" || $status eq "403"){ &repairform("Javascript"); }

	# 404 �G���[�̏ꍇ
	if($status eq "404"){
		$sub_title = qq(404 Not Found | �y�[�W��������܂���);
		$message = qq(
		<strong class="status">- 404 Not Found -</strong><br><br>
		���̃y�[�W�͑��݂��Ȃ����A���ݕ\\�����邱�Ƃ��o���܂���B<br>
		);
		print "Status: 404 NotFound\n";
		$status_flag = 1;
	}

	# 403 �G���[�̏ꍇ
	elsif($status eq "403"){
		$sub_title = qq(403 Fobidden | �y�[�W��������܂���);
		$message = qq(
		<strong class="status">- 403 Fobidden -</strong><br><br>
		���̃y�[�W�͑��݂��Ȃ����A���ݕ\\�����邱�Ƃ��o���܂���B<br>
		);
		print "Status: 403 Forbidden\n";
		$status_flag = 1;
	}

	# 401 �G���[�̏ꍇ
	elsif($status eq "401"){
		$sub_title = qq(401 Unauthorized | �F�؂ł��܂���ł���);
		$message = qq(
		<strong class="status">- 401 Unauthorized -</strong><br><br>
		�F�؂ł��܂���ł����B���������[�U�[���A�p�X���[�h����͂��Ă��������B�B<br>
		);
		print "Status: 401 Unauthorized\n";
		$status_flag = 1;
	}

	# ����ȊO�̏ꍇ
	else{
		print "Status: 404 NotFound\n";
		$status_flag = 1;
	}


# �߂胊���N
my $back_links = qq(
<div class="back_links"> <a href="$door_url">��</a> / <a href="/">�s�n�o�y�[�W��</a> / <a href="javascript:history.back(1)">�O�̉�ʂɖ߂�</a> / <a href="mailto:$basic_init->{'admin_email'}">�Ǘ��҂Ƀ��[��</a> - </div>
);

# HTML
my $print = qq(
<div class="message_box">
$message
$google_box
$back_links
<br>
</div>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}




1;
