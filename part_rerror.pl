use Mebius::Paint;
use Mebius::Text;
use Mebius::BBS;
use Mebius::BBS::Parts;
package main;

#-----------------------------------------------------------
# デスクトップ版 プレビューとエラー
#-----------------------------------------------------------
sub regist_rerror{

# 宣言
my($regist_type);
our($int_dir,$echeck_flag,$css_text);

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }

#push(@css_files,"bbs_all");

# CSS定義
$css_text .= qq(
.middle{color:#f00;font-size:130%;}
.mada{color:#03f;font-weight:normal;font-style:italic;font-size:100%;}
.please_text1{color:#080;font-size:110%;}
.sexvio{color:#f00;font-size:90%;font-weight:bold;}
div.special_error{background:#fcc;padding:0.7em 1em;color:#f00;line-height:2.0em;}
div.error_line{background:#ffeaea;padding:0.7em 1em;color:#f00;line-height:2.0em;}
div.data_line{background:#9fa;padding:0.4em 0.7em;color:#051;line-height:1.8em;}
div.preview_line{background:#ddf;padding:0.4em 1.0em;color:#00f;}
div.paint_image{margin:0.5em 0em 0em 0em;}
);

# CSS定義 ( 他の処理との共通部分 )
$css_text .= qq(
input.wait_input{color:#f00 !important;}
table.table2{width:100%;margin-bottom:1em;}
th.td0{width:0%;}
th.td1{width:50%;}
th.td2{width:21%;}
th.td3{width:21%;}
th.td4{width:8%;white-space:nowrap;}
);

	# スマフォ版
	if($main::device{'smart_flag'}){
		$main::css_text .= qq(.body1{width:100%;}\n);
	}


# 各表示エリアをセット
my($fasterror_line) = &rerror_set_fasterror(@_);
my($preview_line,$index_preview_line) = &rerror_set_preview();
my($error_line) = &rerror_set_error();
my($data_line) = &rerror_set_data();

# 画像添付エリア
if($main::bbs{'concept'} =~ /Upload-mode/){ &upload_setup(); }

# 注意文
if(!$e_com && !$_[0]){
$please_line = qq(
<strong class="mada">
●まだ書き込まれていません。 <input type="submit" value="この内容で送信する"> を押すか、編集フォームで内容を変更してください。</strong><br><br>);
}

# タイトル定義
$sub_title = qq(投稿 | $title);

# 編集フォームを表示
if($in{'res'}){ $regist_type = " RES"; }
else{ $regist_type = " NEW"; }
require "${int_dir}part_resform.pl";
my($resform_line) = &bbs_thread_form("PREVIEW $regist_type");

# ヘッダ
&header();

# ページを表示
print qq(<div class="body1">);

# ナビゲーションリンク
my($navi_links) = Mebius::BBS::ThreadMoveLinks("Thread-top",$main::moto,$main::in{'res'});

print $navi_links;

# フォーム始まり
print qq(
<form action="$script?regist" method="post" name="RESFORM" id="RESFORM"$formtype$sikibetu>
<div class="thread_body bbs_border">
<div class="d">
$fasterror_line
$please_line
$error_line
$data_line
$preview_line
$alert_line
</div></div>
$index_preview_line
);

# ナビゲーションリンク
# ナビゲーションリンク
my($navi_links2) = Mebius::BBS::ThreadMoveLinks("Thread-bottom",$main::moto,$main::in{'res'});

print $navi_links2;

# ページ終わり
print qq($resform_line</form></div>);

# フッタ
&footer();

exit;

}

#-----------------------------------------------------------
# 即時エラー
#-----------------------------------------------------------
sub rerror_set_fasterror{

# 局所化
my($line);

# リターン
if($_[0] eq ""){ return; }

# 表示内容
$line = qq(
<div class="special_error">
<strong class="red">特殊エラー：</strong><br>
▼$_[0]<br>
▼メッセージに従っても状況が改善されない場合は、${mailform}からご連絡いただけます。<br>
　「エラーが起きた場所」「記事のＵＲＬ」「正確なエラーメッセージ」など詳しい情報をお伝えください。<br>
</div><br>
);

return($line);

}


#--------------------------------------------------------------
# 投稿エラー
#--------------------------------------------------------------

sub rerror_set_error{

# 局所化
my($line,$error_text,$pleasechange_text);
our($e_com);

# リターン
if(!$e_com){ return; }

# エラー内容
$error_text = "$e_com";

# エラー表示
$line = qq(
<div class="error_line">
<span class="red">エラー： </span><br>
$error_text
$pleasechange_text
</div>
<br>
);

return($line);

}

#--------------------------------------------------------------
# 予告データ
#--------------------------------------------------------------

sub rerror_set_data{

# 局所化
my($up,$line,$pre_sub,$rer_option,$news_option,$next_charge);
our($nextcharge_minsec,$cgold,$pmfile,%in);

	# リターン
	if($_[0] || $strong_emd){ return; }

	# 新規投稿であれば（投稿データ内容に追加）
	if($in{'res'} eq ""){ $pre_sub = " &gt; <strong>新しい記事</strong>"; }

	# レス投稿の場合、文字数データを表示
	if($in{'res'} ne ""){
		$next_charge .= qq(　<strong>→</strong>　次回チャージは $nextcharge_minsec です$text);
			if($norank_wait){ $next_charge .= qq( (一律)); }
			elsif($cgold >= 1){ $next_charge .= qq(　( 金貨の影響で有利に )); }
			elsif($cgold <= -1){ $next_charge .= qq(　( 金貨の影響で不利に )); }
	}

	# アップするかしないか
	if($in{'res'} ne ""){
			if($in{'up'} eq "1"){ $rer_option = qq(　オプション： 記事を<strong class="red">アップ</strong>); }
			else{ $rer_option = qq(　オプション： なし);}
	}

	# トップ掲載
	#if($in{'news'}){ $news_option = qq( / トップ掲載する); }
	#else{ $news_option = qq( / トップ掲載しない); }


# 投稿データ内容 を定義
$line = qq(<div class="data_line">);
$line .= qq(<strong class="middle">$smlength文字</strong> を投稿);


#if($cgold ne ""){ $line .= qq( ( +<img src="/pct/icon/gold1.gif" alt="金貨" title="金貨"> 現$cgold枚 ) ); }
$line .= qq($next_charge);
#$line .= qq(<br$main::xclose>投稿先： <a href="./">$title</a> $pre_sub $rer_option $news_option);
$line .= qq(</div><br>);

return($line);

}

#--------------------------------------------------------------
# プレビュー
#--------------------------------------------------------------

sub rerror_set_preview{

# 局所化
my($line,$index_preview_line,$pre_res,$name,$id,$trip,$pre_desu);
my(%image,$image_preview);
our($new_res_concept);
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();

# 整形
$trip = qq(☆トリップ) if $enctrip;
	my($id_history_judge) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
	if($id_history_judge->{'record_flag'}){
		$id = qq(<i><a href="./" class="idory" target="_blank" class="blank">★$encid</a></i>);
	}
	else{
		$id = qq(<i>★$encid</i>);
	}

$pre_res = $in{'pre_res'} + 1;
$name = "$i_handle$trip";
	if($my_account->{'login_flag'} && $in{'account_link'}){ $name = qq(<a href="$basic_init->{'auth_url'}$my_account->{'id'}/" target="_blank" class="blank">$name</a>);} 

# 文章エフェクト
($i_com) = Mebius::Text::Effect(undef,$i_com);

# オートリンク
($i_com) = &bbs_regist_auto_link($i_com);

# レスjコンセプトでの整形
my($comment_style) = Mebius::BBS::CommentStyle(undef,$new_res_concept);

# プレビュー宣言
#$pre_desu = qq(<div style="background:#cdf;padding:0.5em 1em;">プレビュー</div><br>);
$pre_desu = qq(<div class="preview_line">プレビュー</div><br>);

	# おえかき画像
	if($in{'image_session'}){
		(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
			if($image{'post_ok'}){
				$image_preview .= qq(<div class="paint_image">);
				$image_preview .= qq(<a href="$image{'image_url_buffer'}">);
				$image_preview .= qq(<img src="$image{'samnale_url_buffer'}" alt="添付画像">);
				$image_preview .= qq(</a>);
				$image_preview .= qq(</div>);
			}

	}

	# 新規投稿の場合
	if ($in{'res'} eq ""){
		$line .= qq(
		$pre_desu
		<b style="color:$in{'color'};">$i_sub</b><br><br>
		<div style="color:$in{'color'};">
		<b>$name</b> $id
		<br><br><span$comment_style>$i_com</span><br>$image_preview<div class="date">$date No.0</div></div><br>
		);
	}

	# レス投稿の場合
	else{
		$line .= qq(
		$pre_desu
		<div style="color:$in{'color'};">
		<b>$name</b> $id<br><br><span$comment_style>$i_com</span><br>$image_preview
		<div class="date">$date No.$pre_res</div></div><br>
		);
	}


	# INDEX プレビュー
	if(!$in{'res'}){
		$index_preview_line = qq(
		<table cellpadding="3" summary="記事一覧" class="table2">
		<tr><th class="td0">印</th><th class="td1">題名</th><th class="td2">名前</th><th class="td3">最終</th><th class="td4"><a name="go"></a>返信</th></tr>
		<tr><td><a href="./">★</a></td><td><a href="./">$i_sub</a></td><td>$i_handle</td><td>$i_handle</td><td>0回</td></tr>
		</table>
		);
	}



return($line,$index_preview_line);

}

1;
