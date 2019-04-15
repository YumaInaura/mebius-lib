
package main;
use Mebius::Export;

#-----------------------------------------------------------
# キーワードページ
#-----------------------------------------------------------
sub auth_wordtag{

# 局所化
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$file,$ads,$i,$form,$myflag,$fook_submit);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
our($selfurl_enc);

# CSS定義
$css_text .= qq(
h1{display:inline;}
table{width:100%;}
th{text-align:left;}
th.name{width:25%;}
th.tag{width:3.25em;}
th,td{padding:0.4em 0.2em;}
.sponsored{font-weight:bold;background-color:#dee;padding:0.3em 0.5em;font-size:90%;border:solid 1px #0aa;}
.ads{}
.comment_input{width:20em;}
div.alert{font-size:90%;background-color:#fff;padding:1em;margin-top:1em;border:solid 1px #f00;}
.google_link{font-size:150%;}
.inline{display:inline;}
.fook_tag{color:#070;margin-left:1.5em;display:inline;font-size:90%;word-spacing:0.3em;}
.fook_input{font-size:80%;width:8em;}
.fook_submit{font-size:80%;}
.inline{display:inline;}
tr.me{background-color:#ff7;padding-left:0.5em;margin:0.3em 0.0em;}
li{line-height:1.7;}
span.alert{font-size:90%;color:#f00;}
);

# タイトル定義
$sub_title = qq($submode3 | SNS タグ);
$head_link3 = qq( &gt; $submode3 - タグ);

$file2 = $submode3;
$file2 =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$file2 =~ tr/ /+/;

my $log_file2 = "${auth_log_directory}_tag/$file2.cgi";

# 閉鎖ファイルをチェック
open(CLOSE_IN,"<","${auth_log_directory}_closetag/${file2}_close.cgi");
$top_close = <CLOSE_IN>;
my($close_key,$admin_alert,$remove) = split(/<>/,$top_close);
close(CLOSE_IN);

# 管理者の警告
if($admin_alert){
$admin_alert_text = &auth_auto_link($admin_alert);
$admin_alert_area = qq(<h2>管理者より</h2><strong class="red">$admin_alert_text</strong>);
}

# キーワードファイルを開く
open(TAG_IN,"<",$log_file2);
	while(<TAG_IN>){
		chomp;
		my($key,$account,$name,$comment,$deleter,$date2) = split(/<>/,$_);

		my($class);
		if($key ne "1" && !$myadmin_flag){ next; }
		if($account eq $pmfile){ $myflag = 1; $comment_value = "$comment"; $class = qq( class="me"); }
		if($key eq "1"){ $i++; }
		if($comment ne ""){ $comment = &auth_auto_link($comment); }
		$line .= qq(<tr$class><td><a href="./$account/">$name - $account</a></td>);
		$line .= qq(<td><a href="./$account/tag-view">→タグ</a></td><td>$comment);


		$line .= qq(</td>);
		$line .= qq(<td>$date2</td>);

		# 削除用リンク
		$line .= qq(<td class="right">);
			if($pmfile eq $account || $myadmin_flag){
				$line .= qq(<a href="./?mode=tag-delete-$file2&amp;account=$account">削除</a>);
					if($myadmin_flag){
						$line .= qq( - ( <a href="./?mode=tag-delete-$file2&amp;account=$account&amp;penalty=1">ペナルティ削除</a> ));
					}
			}
		$line .= qq(</td>);

		$line .= qq(</tr>\n);
	}
close(TAG_IN);

# 登録数ゼロの場合
if(!$i){ $i = 0; }

# リンク切れの場合、修復フォームを表示する
	if(!-f $log_file2 || $close_key eq "0" || $line eq ""){
		&repairform();
	}

# 広告フィルタ判定
my($fillter_flag) = Mebius::Fillter::Ads({ FromEncoding => "sjis" },$submode3);
	Mebius::Fillter::fillter_and_error(utf8_return($submode3));

# 広告
if(!$noads_mode && !$fillter_flag && !$alocal_mode && $i){ $ads = qq(
<br><br>
<div class="sponsored">スポンサードリンク</div><br>
<script type="text/javascript"><!--
google_ad_client = "ca-pub-7808967024392082";
/* SNSビッグバナー */
google_ad_slot = "4432696952";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);
}

# 閉鎖中、ロック中の場合
if($close_key eq "0"){
if($myadmin_flag){ $close_text = qq(<strong class="red">★このタグは閉鎖中です。$admim_alert_text</strong><br><br>); }
else{ &error("このタグは閉鎖中です。$admim_alert_text","410 Gone"); }
}
elsif($close_key eq "2"){
$ads = "";
$close_text = qq(<strong class="red">★このタグはロックされています。$admim_alert_text</strong><br><br>); 
$lock_flag = 1;
}

# ページが存在しない場合
if(!-f $log_file2){ &error("このタグはまだ存在しません。"); }

# 参加中アカウントがない場合
if($line eq ""){ &error("登録がありません。"); }

# ラインの整形(参加アカウントがある場合）
else{
$line = qq(

<h2>参加アカウント ($i)</h2>
<table summary="タグ登録の一覧">
<tr><th class="name">筆名</th><th class="tag">リンク</th><th>コメント</th><th>時刻</th><th></th></tr>
$line
</table>

);
}


# タグ検索フォームを取得
&get_schform;



# 参加中の場合
my($up_input,$edit_input);
if($myflag){
$h22 = qq(コメントを編集);
$edit_input = qq(<input type="hidden" name="edit" value="1">);
$submit_value = qq(コメントを編集する);
$up_input = qq(<input type="checkbox" name="up" value="1"> コメント位置をアップ);
}

# 参加していない場合
else{
$h22 = qq(このタグに参加);
$submit_value = qq(タグ \($submode3\) を追加する);
}

	# タグロック中の場合
	if($lock_flag){}

	# ストップモード
	elsif($main::stop_mode =~ /SNS/){
		$form = qq(<h2>$h22</h2>\n<div><span class="alert">現在、SNS全体で更新停止中です。</span></div>\n);
	}

# キーワード直参加フォーム
elsif($pmfile){
$form = qq(
<h2>$h22</h2>
<form action="$action" method="post" class="myform"$sikibetu>
<div>

<input type="hidden" name="tag" value="$submode3">
コメント： <input type="text" name="comment" value="$comment_value" maxlength="$max_comment" class="comment_input">
<input type="submit" value="$submit_value">
$up_input
$edit_input
<br><span class="alert">※賛同するタグにのみ登録してください。「批判登録」「反対登録」や「タグ内での議論」はご遠慮ください。</span>

<input type="hidden" name="mode" value="tag-maketag">
<input type="hidden" name="plus" value="1">
<input type="hidden" name="account" value="$pmfile">
<br>
<div class="alert">
▲タグ ( $submode3 ) に参加できます。<br>
<span class="red">▲個人情報、本名、性的なキーワード、バッシング目的、非難目的、無意味な単語、迷惑な内容などの登録は禁止です。((<a href="${guide_url}%A5%BF%A5%B0">→タグについて</a>))</span><br>
▲タグは何かに反対したり、何かを攻撃・批判・非難するためものではありません。発言をおこなうには<a href="http://aurasoul.mb2.jp/">掲示板</a>を利用してください。<br>
▲運営要望などは、タグではなく<a href="http://mb2.jp/_qst/">質問運営板</a>までお願いします。<br>
▲不適切なタグ・コメントは<a href="http://mb2.jp/_delete/166.html">【メビリンＳＮＳ】　不正利用報告</a>までご連絡ください。
</div>
</div>
</form>

);


}

# ログインしていない場合
else{
$form = qq(
<h2>$h22</h2>
→このタグに参加するには<a href="${auth_url}?backurl=$selfurl_enc">ログイン（またはメンバー登録）</a>してください。<br>
);
}

# 管理者の場合、キーワード閉鎖フォーム
if($myadmin_flag){
$closelink .= qq(<br><br><form method="post" class="inline" action="$action"><div class="inline">);
$closelink .= qq(<input type="hidden" name="mode" value="tag-close-$file2"$main::xclose>);
$closelink .= qq( <strong class="red">管理者専用：</strong> 説明 <input type="text" name="text" value="$admin_alert" class="comment_input"$main::xclose>);
if($close_text){ $closelink .= qq( <input type="checkbox" name="type" value="revibe" id="tag_revive"$main::xclose> <label for="tag_revive">キーワード復活</label> ); }
else{ $closelink .= qq( <input type="checkbox" name="type" value="close" id="tag_close"$main::xclose><label for="tag_close">キーワード閉鎖</label> ); }
$closelink .= qq( <input type="checkbox" name="type" value="lock" id="tag_lock"$main::xclose><label for="tag_lock">ロック</label> );
$closelink .= qq(<input type="submit" value="設定"$main::xclose>);
$closelink .= qq(</div></form>);
}



# Google検索リンク
my $search_link = qq(
<a href="http://www.google.co.jp/search?q=$file2&amp;sitesearch=mb2.jp&amp;ie=Shift_JIS&amp;oe=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp" class="google_link" rel="nofollow">→”$submode3”をGoogle検索してみる</a><br><br>
);

# ログイン中の場合、タグ登録リンク
my($link1);
if($idcheck){ $navilink = qq(<a href="./$pmfile/tag-view">タグを登録する</a>); }
$navilink .= qq( - <a href="./tag-new.html">新着タグをチェックする</a>);

# HTML
my $print = qq(
$footer_link

<h1>$submode3 - SNSタグ</h1>
$fook_line
<br><br>


$close_text
$search_link
$navilink
$schform
$closelink
$ads
$admin_alert_area
$line
$form
$form2
$footer_link2
);

Mebius::Template::gzip_and_print_all({ no_ads_flag => $fillter_flag },$print);

exit;

}

1;
