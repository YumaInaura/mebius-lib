
use Mebius::BBS::Form;
package main;

#-----------------------------------------------------------
# 携帯版 プレビュー
#-----------------------------------------------------------
sub regist_mobile_rerror{

# 宣言
my($fast_error) = @_;
my(@kcolor,$kback_link_tell);
my($print);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }


# タイトル
$sub_title = qq(投稿 | $title);

# 戻り先
if($in{'res'} ne "") { $kback_link_tell ="$in{'res'}.html"; } else { $kback_link_tell ="kform.html"; }


#ＩＤ，トリップの操作
my $trip = "☆トリップ" if($enctrip);
my $id = "★$encid" if($encid);

if($i_sub){ $ip_sub=""; }
$pre_res = $in{'pre_res'} + 1;

	# 自動リンク
	if($main::bbs{'concept'} =~ /Sousaku-mode/){ ($i_com) = &kauto_link("Thread Omit Preview Loose",$i_com,$main::in{'res'}); }
	else{ ($i_com) = &kauto_link("Thread Omit Preview",$i_com,$main::in{'res'}); }

	if ($in{'res'} eq ""){ $pre_com="$i_sub<br$xclose><br$xclose>0.$i_handle$trip<br$xclose><br$xclose>$i_com<br$xclose>"; }
	else{ $pre_com = "$pre_res.$i_handle$trip<br$xclose><br$xclose>$i_com<br$xclose>"; }

	# プレビューの表示内容（返信時）-----
	if($in{'preview'}){

		if(!$e_com){ $pleasepost_text = qq(<br$xclose>良ければ<input type="submit" value="#送信"$xclose>してください。); }

		# 予告
		my($gold);
		if($cgold eq ""){ $gold = "0枚"; }
		else{ $gold = "$cgold枚"; }
		$pre_body .= qq(<div style="background:#9ee;$ktextalign_center_in$kborder_top_in">予\告</div>);
		$pre_body .= qq(<div style="margin:0.3em 0em;">投稿 $smlength文字 ┃ );
		$pre_body .= qq( <img src="/pct/icon/gold2.gif" alt="金貨" title="金貨"$xclose> $gold);
		$pre_body .= qq(<br$main::xclose><span style="color:#077;">→次回チャージ $nextcharge_minsec $kfight_text1</span></div>);

		# プレビュー
		$pre_body .= qq(<div style="background:#ddf;$ktextalign_center_in$kborder_top_in">プレビュー(未投稿)</div>);

		# 新規投稿
		if($in{'res'} eq ""){
			$pre_body .= qq(<div style="margin:0.3em 0em;">);
			$pre_body .= qq($i_sub<br$xclose><br$xclose>0.$i_handle$trip$id<br$xclose>);
			$pre_body .= qq(<span style="color:$in{'color'};">$i_com</span><br$xclose>$date);
			$pre_body .= qq(</div>);
		}

		# レス投稿
		else{
			$pre_body .= qq(<div style="margin:0.3em 0em;color:$in{'color'}">);
			$pre_body .= qq($i_handle$trip$id<br$xclose>);
			$pre_body .= qq($i_com<br$xclose>$date$pleasepost_text);
			$pre_body .= qq(</div>);
		}
	}

# 投稿前チェック
if($e_com){

if(!$strong_emd) { $pleasechange_text = qq(→$emoji_shift_jis->{'number5'}<a href="#ARESFORM">編集ﾌｫｰﾑ</a>で修正出来ます。); }

$error_body = qq(
<div style="background:#fbb;$ktextalign_center_in$kborder_top_in">投稿エラー</div>
<div style="color:#f00;font-size:small;">
$e_com
$pleasechange_text
</div>
);
}


$in{'comment'} =~ s/<br>/\n/g;

# 画像添付エリア
if($main::bbs{'concept'} =~ /Upload-mode/){ require "${int_dir}def_secret.pl"; &upload_setup("k"); }

if($fast_error){ $fast_error = qq(<strong style="color:#f00;">特殊エラー：</strong> $fast_error<hr$xclose>); }
my($allview) = qq($fast_error $error_body $pre_body $alert_body);
$allview =~ s/<br>/<br$xclose>/g;

$print .= qq(
<form action="$script" method="post" name="rerror"$formtype$sikibetu><div>
$allview
);

if ($in{'res'} ne "") { $print .= qq(<input type="hidden" name="res" value="$in{'res'}"$xclose>\n); }

$print .= qq(<div style="background:#9f9;$ktextalign_center_in$kborder_top_in">);
$print .= qq($emoji_shift_jis->{'number5'}<a href="#ARESFORM" id="ARESFORM" accesskey="5">編集</a>$emoji_shift_jis->{'write'});
$print .= qq(</div>);

if ($in{'res'} eq "") {
$print .= <<"EOM"
題<input type="text" name="sub" class="input" size="14" value="$in{'sub'}" maxlength="50"$xclose><br$xclose>
EOM
}

# MAX-LENGTH
my $maxlength_name = qq( maxlength="50");

$print .= qq(筆名<input type="text" name="name" size="14" class="input" value="$in{'name'}"$maxlength_name$xclose>);

# 文字色

my(@color) = Mebius::Init::Color();

$print .= qq(色<select name="color">);
	foreach(@color) {
		my($name,$code) = split(/=/);
			if($code eq $in{'color'}) { $print .= qq(<option value="$code" style="color:$code;"$main::parts{'selected'}>$name</option>\n); }
			else { $print .= qq(<option value="$code" style="color:$code;">$name</option>\n); }
	}

$print .= qq(</select>);
$print .= qq(<br$xclose>);

# 投稿ボタン
$submit_botton = qq(<input type="submit" name="preview" value="*確認" accesskey="*"$xclose>
<input type="submit" value="#送信" accesskey="#"$xclose>);

# 性表現、暴力表現のチェック
if($i_res eq ""){ require "${int_dir}part_sexvio.pl"; &sexvio_form(); }

# テキストエリアの内容
my $intextarea = qq($in{'comment'});
$intextarea =~ s/\[REFERER\]//g;

# テキストエリア
$print .= qq(
<textarea cols="25" rows="5" name="comment">$intextarea</textarea><br$xclose>
$input_upload
$viocheck$sexcheck
<span style="font-size:small;">
);


my $form_parts = new Mebius::BBS::Form;

	# Up ボックス
	if ($in{'res'} ne "") {
		$print .= ($form_parts->thread_up({ MobileView => 1 , from_encoding => "sjis" }));
		#if ($in{'up'} == 1) { print"<input type=\"checkbox\" name=\"up\" value=\"1\"$checked$xclose>ｱｯﾌﾟ"; }
		#else{ print"<input type=\"checkbox\" name=\"up\" value=\"1\"$xclose>ｱｯﾌﾟ";}
	}
	elsif($in{'up'} == 1) {
		$print .= ($form_parts->thread_up({ Hidden => 1 , MobileView => 1 , from_encoding => "sjis" }));
	}

# TOP新着ボックス
#if($secret_mode){ $print .= qq(<input type="hidden" name="news" value="$cnews"$xclose>); }
#else{
#if($in{'news'}){ $print .= qq(<input type="checkbox" name="news" value="1"$checked$xclose>新着); }
#else{ $print .= qq(<input type="checkbox" name="news" value="1"$xclose>新着); }
#}

	# ID履歴
	#$print .= (Mebius::BBS::id_history_input_parts({ from_encoding => "sjis" }));

	# アカウントへのリンク
	$print .= ($form_parts->account_link({ from_encoding => "sjis" , MobileView => 1 }));

$print .= qq(
</span>
<div style="text-align:right;">
$submit_botton
</div>
<input type="hidden" name="mode" value="regist"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="pre_res" value="$in{'pre_res'}"$xclose>
<input type="hidden" name="k" value="1"$xclose>
<input type="hidden" name="access_time" value="$in{'access_time'}"$xclose>
<input type="hidden" name="resnum" value="$in{'resnum'}"$xclose>
$main::backurl_input
</div>
</form>
);


Mebius::Template::gzip_and_print_all({},$print);


exit; 

}

#-------------------------------------------------
# 携帯版 投稿時のリンク処理
#-------------------------------------------------
sub reist_autolink_mobile {
local($msg) = @_;

($msg) = Mebius::auto_link($msg);




$msg;
}



1;
