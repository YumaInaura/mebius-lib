
#-----------------------------------------------------------
# Not Found エラーページ - strict
#-----------------------------------------------------------
sub main_errorpage{

# 宣言
my($google_box);
our($css_text,$submode2,$headflag,$status_flag,$alocal_mode,$body_javascript,$google_box,$google_oe,$referer);
our($alocal_mode);


# CSS定義
$css_text .= qq(
.message_box{padding:30px 5%;width:70%;margin:0em auto 1em auto;text-align:center;border:1px #000000 solid;}
strong.status{color:#f00;font-size:110%;}
.vertical{vertical-align:middle;}
.back_links{font-size:90%;word-spacing:0.2em;}
.index_find{margin:1em 0em;}
.index_find2{margin:1em 4em;text-align:left;background:#dee;padding:1em;font-size:90%;font-weight:normal;}
b{color:#000;font-weight:normal;}
);

	# ローカル
	if($alocal_mode){
		$referer = "http://localhost/_test/1281.html";
	}


# Body Javascript 定義
$body_javascript = qq( onload="document.google.q.focus()");

# Google 検索ボックス
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

# Google検索ボックス
$google_box = qq(
<form method="get" action="http://www.google.co.jp/search" class="index_find" name="google"> 
<div>
<a href="http://www.google.co.jp/" rel="nofollow">
<img src="http://www.google.co.jp/logos/Logo_25wht.gif" class="google_img vertical" alt="Google"></a>
<input type="text" name="q" size="41" maxlength="255" value="" class="vertical">
<input type="submit" name="btnG" value="メビウスリングを検索" class="vertical">
<input type="hidden" name="sitesearch" value="mb2.jp">
<input type="hidden" name="ie" value="Shift_JIS">
$google_oe
<input type="hidden" name="hl" value="ja">
<input type="hidden" name="domains" value="mb2.jp">
</div>
</form>
);

	# モード振り分け
	if($submode2 eq "404"){ &main_errorpage_view("","404",$google_box); }
	elsif($submode2 eq "403"){ &main_errorpage_view("","403",$google_box); }
	elsif($submode2 eq "401"){ &main_errorpage_view("","401",$google_box); }
	else{ &error("ほんとに NotFound"); }

exit;

}

#-----------------------------------------------------------
# 各種エラー - strict
#-----------------------------------------------------------
sub main_errorpage_view{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type,$status,$google_box) = @_;
my($message);
our($back_links,$sub_title,$referer,$door_url,$int_dir,$requri,$selfurl);

# リダイレクトミスがある場合、別枠で記録
if($requri =~ /%23/){ Mebius::AccessLog(undef,"REDIRECT-MISSED","$status	Dead-link http://$server_domain$requri	Referer $referer	$date"); }

# リンク切れページを記録
Mebius::AccessLog(undef,"$status","$status	Dead-link http://$server_domain$requri	Referer $referer	$date");


# 自動リンク切れ修正
if($status eq "404" || $status eq "403"){ &repairform("Javascript"); }

	# 404 エラーの場合
	if($status eq "404"){
		$sub_title = qq(404 Not Found | ページが見つかりません);
		$message = qq(
		<strong class="status">- 404 Not Found -</strong><br><br>
		このページは存在しないか、現在表\示することが出来ません。<br>
		);
		print "Status: 404 NotFound\n";
		$status_flag = 1;
	}

	# 403 エラーの場合
	elsif($status eq "403"){
		$sub_title = qq(403 Fobidden | ページが見つかりません);
		$message = qq(
		<strong class="status">- 403 Fobidden -</strong><br><br>
		このページは存在しないか、現在表\示することが出来ません。<br>
		);
		print "Status: 403 Forbidden\n";
		$status_flag = 1;
	}

	# 401 エラーの場合
	elsif($status eq "401"){
		$sub_title = qq(401 Unauthorized | 認証できませんでした);
		$message = qq(
		<strong class="status">- 401 Unauthorized -</strong><br><br>
		認証できませんでした。正しいユーザー名、パスワードを入力してください。。<br>
		);
		print "Status: 401 Unauthorized\n";
		$status_flag = 1;
	}

	# それ以外の場合
	else{
		print "Status: 404 NotFound\n";
		$status_flag = 1;
	}


# 戻りリンク
my $back_links = qq(
<div class="back_links"> <a href="$door_url">扉</a> / <a href="/">ＴＯＰページへ</a> / <a href="javascript:history.back(1)">前の画面に戻る</a> / <a href="mailto:$basic_init->{'admin_email'}">管理者にメール</a> - </div>
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
