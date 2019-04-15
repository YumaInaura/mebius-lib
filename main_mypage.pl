
package main;

#-----------------------------------------------------------
# マイページ
#-----------------------------------------------------------
sub main_mypage{

# 局所化
my($bbs,$back,$bbs_link,$back_link,$follow_line);
my($oneline,$message_line,$edit_form);
our(%in,$backurl,$backurl_link,$kflag,$noindex_flag);
my($q) = Mebius::query_state();
my $html = new Mebius::HTML;
my $history = new Mebius::History;

# 検索よけ
$noindex_flag = 1;

# 携帯モード ( 消去しない。 &backurl(); より前に必要 )
# 携帯アイテム
if($main::device{'type'} eq "Mobile"){ kget_items(""); }

# 名前最大文字数
$maxnam = 10;

# 文字サイズの種類
@moji_size = (60,70,80,90,100,110,120,130,140,150);

# 画面幅の種類
@width_size = (50,60,70,80,85,90,95,100);

# CSS定義
$css_text .= qq(
h2{display:inline;font-size:120%;clear:both;}
div.h2{background:#bbb;padding:0.3em 0.5em;margin:1em 0em;}
div.domain_list{background:tranceparent;color:#080;font-size:90%;text-align:right;margin:0.5em;}
div.RESHISTORY{background:#9e9;}
div.FOLLOW{background:#7cf;}
div.MESSAGE{background:#ff5;}
div.EDIT{background:#7bb;}
div.RECORD{background:#fbb;}
div.CERMAIL{background:#fa4;}
div.CHECKHISTORY{background:#acf;}
hr{margin:1em 0em 1em 0em;}
li{line-height:1.5em;}
.alert{color:#f00;font-size:80%;}
.navi_link{font-size:90%;}
ul{margin:1em 0em;}
div.history_flow{text-align:right;margin:1em 0em;}
td{vertical-align:top;}
div.fillter_guide{padding:1em;margin:1em 0.5em;font-size:80%;border:solid 1px #080;line-height:1.4em;}
i{background:#99f;margin:0em 0.5em 0em 0em;}
);

	# スマフォ版CSS
	if($main::device{'smart_flag'}){
		$main::css_text .= qq(div.page1{padding:0.5em;border:}\n);
		
	}
	# それ以外のCSS
	else{
		$main::css_text .= qq(.tdleft{white-space:nowrap;}\n);
		$main::css_text .= qq(input.select1,select.select1{width:15em;}\n);
		$main::css_text .= qq(div.page1{padding:2em 2em;border:solid 1px #555;}\n);
	}

# タイトル定義
my $sub_title = "マイページ - $server_domain";
#$head_link1 = qq( &gt; <a href="http://aurasoul.mb2.jp/">通常版</a> | <a href="http://mb2.jp/">娯楽版</a> );
$head_link3 = " &gt; マイページ";

	# 変更処理
	if($in{'csubmit'}){ &mysubmit(); }
	elsif($in{'type'} eq "control_history"){ control_new_system_history_mypage(); }

# 送信先
$my_action = "./";

# メールアドレスの認証チェック
#local($cermail_td) = email_form_mypage();

# ドメイン切り替えリンク
my($domain_list) = main_mypage_domainlist();

#<a href="#FOLLOW">▼フォロー</a> -

	# ナビゲーションリンク
	if(!$kflag){
		$navi_link .= qq(
		<div class="navi_link">
		<a href="/">ＴＯＰページ</a> - );
			if($backurl){ $navi_link .= qq($backurl_link - ); }
	}
	else{ $navi_link .= qq(<div style="font-size:small;">); }
$navi_link .= qq(<a href="./?mode=settings">設定</a> -\n);
	if(!$kflag){ $navi_link .= qq(<a href="#CERMAIL">▼お知らせメール</a> -\n); }
$navi_link .= qq(<a href="#RECORD">▼成績</a>\n);
	if(!$kflag){
		$navi_link .= qq(　<span class="red">/　現在 $thisyear年 $thismonth月$today日 $thishour時$thismin分 </span>);
	}
$navi_link .= qq(</div>);


# 投稿履歴を取得
#my($reshistory_line) = main_mypage_reshistory();
my $reshistory_line .= qq(<div class="h2 RESHISTORY"><h2 id="RESHISTORY">投稿履歴</h2></div>);
$reshistory_line .= qq(<form action="" method="post">);
$reshistory_line .= $html->input("hidden","mode","my");
$reshistory_line .= $html->input("hidden","type","control_history");
$reshistory_line .= shift_jis($history->my_history_index());
$reshistory_line .= qq(<div class="right"><input type="submit" value="削除"></div>);
$reshistory_line .= qq(</form>);

	# お知らせメール登録リストを取得
	if($cookie && !$kflag){ getlist_cermail(); }

# これまでの成績を取得
get_myrecord();

# HTML
my $print .= qq(<div class="page1">);

	# 設定変更フォームを取得
	if($q->param('mode') eq "settings"){
			$print .= qq(	<h1$main::kfontsize_h1>設定</h1>);
			my($edit_form) = get_editform();
			$print .= $edit_form;
	} else {

			# HTML
			if(!$kflag){
				$print .= qq(	<h1$main::kfontsize_h1>マイページ</h1>$navi_link);
			}

			if($kflag){
				$print .= qq(<h1$main::kfontsize_h1>マイページ</h1>);
			}

			# 各種ライン表示 ( デスクトップ )
			if(!$kflag){
				$print .= qq(
				$reshistory_line
				$follow_line
				$mylist
				$list_cermail
				$message_line
				$myrecord
				$edit_form
				);
			}

			# 各種ライン表示 ( モバイル )
			else{
				$print .= qq(
				$navi_link
				$reshistory_line
				$follow_line
				$mylist
				$list_cermail
				$message_line
				$myrecord
				$edit_form
				);
			}

	}

# 管理者にクッキーの要素を表示
($print) .= main_mypage_cookielist();

$print .= qq(<br$xclose></div>);

# フッタ
Mebius::Template::gzip_and_print_all({ Title => $sub_title },$print);

exit;

}

#-----------------------------------------------------------
# 投稿履歴を表示
#-----------------------------------------------------------
sub main_mypage_reshistory{

# 宣言
my($line,$maxview,$none,$flow,$postbuf_enc);
our(%in,$kflag,$postbuf);

# 表示最大数
$maxview = 20;
	if($kflag){ $maxview = 5; }
	if($in{'viewmax'}){ $maxview = 50; }
	if(!Mebius::Server::bbs_server_judge()){ return(); }

# 投稿履歴を取得
require "${main::int_dir}part_history.pl";
my($none,$none,$res_history_line,$res_history_flow) = &get_reshistory("INDEX THREAD My-file Mypage-view Allow-renew-status",undef,undef,undef,$maxview);
my($none,$none,$crap_history_line,$crap_history_flow) = &get_reshistory("INDEX THREAD Crap-file My-file Mypage-view Allow-renew-status",undef,undef,undef,$maxview);
my($none,$none,$check_history_line,$check_history_flow) = &get_reshistory("INDEX THREAD Check-file My-file Mypage-view Allow-renew-status",undef,undef,undef,$maxview);

# リンク先
$postbuf_enc = $postbuf;
$postbuf_enc =~ s/&/&amp;/g;

	# 整形
	if($res_history_line){

		my($domain_list) = &main_mypage_domainlist("RESHISTORY");

			if($res_history_flow){
				$res_history_line = qq(<div class="h2 RESHISTORY"><h2 id="RESHISTORY"$main::kfontsize_h2><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#RESHISTORY">投稿履歴</a></h2></div>$res_history_line);
				$res_history_line .= qq(<div class="history_flow"><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#RESHISTORY">→続きを表\示する</a></div>$domain_list);
			}
			else{
				$res_history_line = qq(<div class="h2 RESHISTORY"><h2 id="RESHISTORY"$main::kfontsize_h2>投稿履歴</h2></div>$res_history_line$domain_list);
			}
	}

	# 整形
	if($crap_history_line){

		my($domain_list) = &main_mypage_domainlist("CRAPHISTORY");

			if($crap_history_flow){
				$crap_history_line = qq(<div class="h2 CRAPHISTORY"><h2 id="CRAPHISTORY"$main::kfontsize_h2><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CRAPHISTORY">投稿履歴</a></h2></div>$line);
				$crap_history_line .= qq(<div class="history_flow"><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CRAPHISTORY">→続きを表\示する</a></div>$domain_list);
			}
			else{
				$crap_history_line = qq(<div class="h2 CRAPHISTORY"><h2 id="CRAPHISTORY"$main::kfontsize_h2>いいね！履歴</h2></div>$crap_history_line$domain_list);
			}
	}

	# 整形
	if($check_history_line){

		my($domain_list) = &main_mypage_domainlist("CHECKHISTORY");

			if($check_history_flow){
				$check_history_line = qq(<div class="h2 CHECKHISTORY"><h2 id="CHECKHISTORY"$main::kfontsize_h2><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CHECKHISTORY">投稿履歴</a></h2></div>$line);
				$check_history_line .= qq(<div class="history_flow"><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CHECKHISTORY">→続きを表\示する</a></div>$domain_list);
			}
			else{
				$check_history_line = qq(<div class="h2 CHECKHISTORY"><h2 id="CHECKHISTORY"$main::kfontsize_h2>チェック履歴</h2></div>$check_history_line$domain_list);
			}
	}


$line = $res_history_line . $crap_history_line . $check_history_line;

return($line);

}

#-----------------------------------------------------------
# 設定変更フォームを取得
#-----------------------------------------------------------
sub get_editform{

my($line,$record_crireki_checkbox);
my($checked_end,$checked_start,$chandle,$ctrip_value);

my($domain_list) = &main_mypage_domainlist("EDIT");

# 名前とトリップを分ける
my($handle_value,$trip_value) = split(/#/, $main::cnam,2);

$line .= qq(
<div class="h2 EDIT"><h2 id="EDIT"$main::kfontsize_h2>掲示板の設定</h2></div>
<form action="$my_action" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="my"$xclose>
$backurl_input
<table style="border-style:none;">
);

# 端末切り替えフォーム
my($device_switch_form) = shift_jis(get_device_type_form_mypage());
$line .= $device_switch_form;

# 筆名他
$line .= qq(

<tr title="あなたのハンドルネームを設定してください。">
<td class="tdleft"><label for="cnam"><strong>筆名</strong></label></td>
<td><input type="text" name="cnam" value="$handle_value" size="20" maxlength="20" class="select1" id="cnam"$xclose>
（本名禁止、全角10文字まで）</td>
</tr>

<tr title="偽者防止です。好きな文字列を入力してください。">
<td><label for="ctrip"><strong><a href="${guide_url}%A5%C8%A5%EA%A5%C3%A5%D7" class="blank" target="_blank" placeholder="りんご">トリップの素</a></strong></label></td><td>
<input type="text" name="ctrip" value="$trip_value" size="20" maxlength="20" class="select1" id="ctrip"$xclose>
（半角20文字、全角10文字まで。推測されにくいものを）
</td></tr>
);

# メルアド認証
$line .= qq($cermail_td);

# 年齢設定
($line) .= &age_form();

# 文字省略フォーム
($line).= &get_ccutform();

# 画像オンオフ切替フォーム
#($line) .= &get_imagelink_form_mypage();

	# 文字サイズ
	if(!$kflag){
		$line .= qq(<tr><td><label for="cfontsize"><strong>文字サイズ</strong></label></td><td>
		<select name="cfontsize" id="cfontsize" class="select1">);

		$select_cfontsize = $cfontsize;
		if(!$cfontsize){$select_cfontsize = 100;}
		foreach(@moji_size){
		if($select_cfontsize == $_){ $line .= qq(<option value="$_"$selected>文字サイズ $_％</option>\n); }
		else{ $line .= qq(<option value="$_">文字サイズ $_％</option>\n); }
		}
		$line .= qq(</select></td></tr>);
	}


	# 投稿後のジャンプ
	if(!$kflag && 0){
		my @cposted = ("0","1","2","3","4","5","6","7","8","9","10","15","20","25","30","45","60");
		$line .= qq(<tr title="掲示板に書き込んだ後に、自動ジャンプする秒数を設定します。"><td class="tdleft"><label for="cposted"><strong>投稿後のジャンプ</strong></label></td><td><select name="cposted" id="cposted" class="select1">);
		foreach (@cposted){
		if(($cposted eq "" || $cposted eq "default") && $_ == 3){ $line .= qq(<option value="default"$selected>$_秒後にジャンプ (デフォルト)</option>\n); }
		elsif($_ eq $cposted){ $line .= qq(<option value="$_"$selected>$_秒後にジャンプ</option>\n); }
		else{ $line .= qq(<option value="$_">$_秒後にジャンプ</option>\n); }
		}
		if($cposted eq "direct"){ $line .= qq(<option value="direct"$selected>瞬時にジャンプ</option>\n); }
		else{ $line .= qq(<option value="direct">瞬時にジャンプ</option>\n); }
		if($cposted eq "auto"){ $line .= qq(<option value="auto"$selected>チャージ終了時にジャンプ</option>\n); }
		else{ $line .= qq(<option value="auto">チャージ終了時にジャンプ</option>\n); }
		if($cposted eq "off"){ $line .= qq(<option value="off"$selected>ジャンプしない</option>\n); }
		else{ $line .= qq(<option value="off">ジャンプしない</option>\n); }
		$line .= qq(</select></td></tr>);
	}

# フォロー機能
$line .= qq(<tr><td><label for="cfollow"><strong>フォロー機能\</strong></label></td><td><select name="cfollow" id="cfollow" class="select1">);
my($selected1,$selected2);
$selected1 = $selected;
if($cfollow eq "off"){ $selected2 = $selected; $selected1 = ""; }
$line .= qq(
<option value="on"$selected1>フォロー機能\を使う</option>
<option value="off"$selected2>フォロー機能\を使わない</option>
);
$line .= qq(</select>　<span class="guide" style="font-size:small;">※”使わない”を選ぶと今のフォロー内容もリセットされます。</span>
</td></tr>);


# 投稿履歴の選択
$record_crireki_checkbox .= qq(<select name="record_crireki" id="record_crireki">\n);
	if($crireki eq "off"){ $checked_end = $main::parts{'selected'}; }
	else{ $checked_start = $main::parts{'selected'}; }
		$record_crireki_checkbox .= qq(<option value="start"$checked_start>記録する</option>\n);
		$record_crireki_checkbox .= qq(<option value="off"$checked_end>記録しない</option>\n);
		$record_crireki_checkbox .= qq(<option value="reset">記録をリセットする</option>\n);
		$record_crireki_checkbox .= qq(</select>\n);

# 説明
$record_crireki_checkbox .= qq(<span style="color:#080;" class="guide">※公開用の履歴(アカウント/ID/トリップ毎)には反映されません。(<a href="${main::guide_url}%A5%C8%A5%EA%A5%C3%A5%D7" target="_blank" class="blank">→トリップガイド</a>)</span>);



# 投稿履歴
$line .= qq(
<tr>
<td><label for="record_crireki"><strong>投稿履歴</strong></label></td>
<td>
$record_crireki_checkbox
$rireli_line
</td>
</tr>
);


# 簡易フィルタフォーム
($line) .= &get_fillter_form_mypage();

# 変更するボタン、フォーム終わり -----

$line .= qq(
<tr><td></td><td>
<input type="hidden" name="csubmit" value="1"$xclose>
<input type="submit" value="この内容で変更する" class="isubmit"$xclose>
<input type="submit" name="backurl_on" value="変更して元のページに戻る" class="isubmit"$xclose>

$backurl_checkbox
</td></tr></table>
</div></form>
$domain_list
);



return($line);

}

#-----------------------------------------------------------
# 携帯版の文字数省略
#-----------------------------------------------------------
sub get_ccutform{

my($line,$select);
my($selected1,$selected1_5,$selected0,$selected2,$selected3);

	# ＰＣ版
	if($main::device{'type'} ne "Mobile"){
			if($ccut eq "1" || $ccut eq ""){ $line .= qq(<input type="hidden" name="ccut" value="1">); }
			else{ $line .= qq(<input type="hidden" name="ccut" value="$ccut">); }
		return($line); 
	}

	if($ccut eq "1" || $ccut eq ""){ $selected1 = $selected; }
	if($ccut eq "0"){ $selected0 = $selected; }
	if($ccut eq "1.5"){ $selected1_5 = $selected; }
	if($ccut eq "2"){ $selected2 = $selected; }
	if($ccut eq "3"){ $selected3 = $selected; }

$select .= qq(<select name="ccut" class="select1">\n);
$select .= qq(<option value="1"$selected1>省略する(普通)</option>);
$select .= qq(<option value="1.5"$selected1_5>省略する(1.5倍)</option>);
$select .= qq(<option value="2"$selected2>省略する(2倍)</option>);
$select .= qq(<option value="3"$selected3>省略する(3倍)</option>);
$select .= qq(<option value="0"$selected0>省略しない</option>);
$select .= qq(</select>);

$line = qq(
<tr><td><strong>レス省略</strong></td><td>$select<span style="font-size:small;color:#f00;">※ページが途切れる場合は「省略する(普通)」を選んでください。</span></td></tr>
);

return($line);

}

#-----------------------------------------------------------
# 画像表示のオンオフ切り替えフォーム
#-----------------------------------------------------------
sub get_imagelink_form_mypage{

my($line,$select);
my($selected_on,$selected_hide);
our($cimage_link,$selected);

# 選択
if($cimage_link eq "hide"){ $selected_hide = $selected; }
if($cimage_link eq "on"){ $selected_on = $selected; }

$select .= qq(<select name="cimage_link" id="cimage_link" class="select1">\n);
$select .= qq(<option value="on"$selected_on>普通に表\示する</option>);
$select .= qq(<option value="hide"$selected_hide>画像を隠す</option>);
$select .= qq(</select>);

$line = qq(
<tr><td><label for="cimage_link"><strong>お絵かき絵の表\示</strong></label></td><td>$select</td></tr>
);

return($line);

}

use strict;


#-----------------------------------------------------------
# 年齢設定フォーム
#-----------------------------------------------------------
sub age_form{

my($line,$i);
our($cage,$disabled,$selected,$xclose,$thisyear);

# 年齢設定済みの場合
if($cage && 1 == 0){
$line .= qq(<tr><td><label for="cage"><strong>生年(非公開)</strong></label></td>);
$line .= qq(<td><select name="cage" class="select1" id="cage"$disabled>\n);
$line .= qq(<option value="$cage">$cage 年生まれ</option>\n);
$line .= qq(</select></td></tr>);
$line .= qq(<input type="hidden" name="cage" value="$cage"$xclose>);
}


# 年齢未設定の場合
else{
my($i);
$line .= qq(<tr><td><label for="cage"><strong>生年(非公開)</strong></label></td>);
$line .= qq(<td><select name="cage" class="select1" id="cage">\n<option value="0"> 未選択</option>\n);
$i = $thisyear;
for(1..130){
$i--;
if($i eq $cage){ $line .= qq(<option value="$i"$selected>$i年 生まれ</option>\n); }
else{ $line .= qq(<option value="$i">$i年 生まれ</option>\n); }
}


$line .= qq(</select></td></tr>);
}

return($line);

}


no strict;


#-----------------------------------------------------------
# 簡易フィルタ
#-----------------------------------------------------------
sub get_fillter_form_mypage{

# 宣言
my($type) = @_;
my($line,$id_fillter_view,$account_fillter_view);

# 初期入力値
my $cfillter_id_inputed = $main::cfillter_id;
my $cfillter_account_inputed = $main::cfillter_account;

	# 現在のフィルタ設定を展開
	foreach(split(/\s/,$main::cfillter_id)){
		$id_fillter_view .= qq(<i>★$_</i>\n);
	}

$line .= qq(<tr><td><label for="cfillter_id"><strong>IDフィルタ</strong></label></td>);
$line .= qq(<td>);
$line .= qq(<input type="text" name="cfillter_id" id="cfillter_id" value="$cfillter_id_inputed" style="width:50%;"$main::xclose>);
if($id_fillter_view){ $line .= qq(<br$main::xclose>$id_fillter_view); }
$line .= qq(</td>);
$line .= qq(</tr>);


	# 現在のフィルタ設定を展開
	foreach(split(/\s/,$main::cfillter_account)){
		$account_fillter_view .= qq(<a href="${main::auth_url}$_/">$_</a>\n);
	}


$line .= qq(<tr><td><label for="cfillter_account"><strong>アカウントフィルタ</strong></label></td>);
$line .= qq(<td>);
$line .= qq( <input type="text" name="cfillter_account" id="cfillter_account" value="$cfillter_account_inputed" style="width:50%;"$main::xclose>);
	if($account_fillter_view){ $line .= qq(<br$main::xclose>$account_fillter_view); }
$line .= qq(<div class="fillter_guide"><span style="color:#080;">掲示板の記事で、特定ユーザーの投稿を非表\示に出来ます。（相手には通知されません）);
$line .= qq(<br$main::xclose>それぞれＩＤ/アカウント名を入力してください。複数指定する場合は、スペースで区切ってください。 );
$line .= qq(</span></div>);
$line .= qq(</td>);
$line .= qq(</tr>);

return($line);


}

use strict;

#-----------------------------------------------------------
# メッセージを取得 (非使用)
#-----------------------------------------------------------
sub getlist_message{

# 宣言
my($oneline,$message_line,$maxview_line,$index_flow,$h2,$flow_href,$moreview_link);

# 表示行数を設定
$maxview_line = 5;
if($main::in{'viewmax'}){ $maxview_line = 100; }

# ドメインリストを取得
my($domain_list) = &main_mypage_domainlist("MESSAGE");

	# メッセージを取得 （アカウント）
	if($main::pmfile){
		my($plustype) = " CHECK RENEW" if($main::in{'message_check'});
		require "${main::int_dir}part_idcheck.pl";
		($message_line,$index_flow) = &call_savedata_message("ACCOUNT INDEX $plustype",$main::pmfile,"","",$maxview_line);
	}

	# メッセージを取得 （携帯の固体識別番号）
	elsif($main::kaccess_one){
		my($plustype) = " CHECK RENEW" if($main::in{'message_check'});
		require "${main::int_dir}part_idcheck.pl";
		($oneline,$message_line) = &call_savedata_message("MOBILE INDEX $plustype",$main::kaccess_one,$main::k_access,"","",$maxview_line);
	}

	# flow している場合の整形
	if($message_line && $index_flow && !$main::in{'viewmax'}){
$flow_href = qq(./?$main::postbuf_query_esc&amp;viewmax=1$main::backurl_query_enc#MESSAGE);
$h2 = qq(<h2 id="MESSAGE"$main::kfontsize_h2><a href="$flow_href">メッセージ</a></h2>);
$moreview_link = qq(<div class="flow"><a href="$flow_href">→続きを表\示する</a></div>);
	}

	# flowしていない場合の整形
	else{
$h2 = qq(<h2 id="MESSAGE"$main::kfontsize_h2>メッセージ</h2>);
	}

	# メッセージ行の整形
	if($message_line){
$message_line = qq(
<div class="h2 MESSAGE">$h2</div>
$message_line
$moreview_link
$domain_list
);
	}

# リターン
return($message_line);

}

no strict;

#-----------------------------------------------------------
# お知らせメールのリストを取得
#-----------------------------------------------------------
sub getlist_cermail{

# 局所化
my($cancel_link,$FILE);
my($myaddress) = Mebius::my_address();

# ファイル定義
my($file) = Mebius::Encode(undef,$myaddress->{'address'});

	# メルアド毎のキャリアファイルを開く
	if($file){

		open($FILE,"<","${main::int_dir}_address/$file/bbs_thread_career.dat");
				while(<$FILE>){
					my($link1,$subject_view);
					chomp;
					my($no2,$moto2,$subject_while,$bbs_title_while) = split(/<>/,$_);
					my($res,$lasttime);# = &get_thread($no2,$moto2,$title);
					$list_cermail .= qq(<li>);
						if($subject_while){ $subject_view = $subject_while; } else { $subject_view = "$moto2-$no2"; }

					$list_cermail .= qq(<a href="/_$moto2/$no2.html">$subject_view</a>);
						if($bbs_title_while){ $list_cermail .= qq( &lt; <a href="/_$moto2/">$bbs_title_while</a>); }
					$list_cermail .= qq( - <a href="/_$moto2/?mode=cermail&amp;type=cancel&amp;no=$no2&amp;my=1">配信解除</a>);

				}
		close($FILE);
	}

# ドメイン切り替えリンクを定義
my($domain_list) = &main_mypage_domainlist("CERMAIL");

# 内容がある場合
if($list_cermail){
$list_cermail = qq(
<div class="h2 CERMAIL"><h2 id="CERMAIL"$main::kfontsize_h2>お知らせメール登録</h2></div>
<ul>
$list_cermail
</ul>
$domain_list
);
}
# 内容が無い場合
else{
$list_cermail = qq(
<div class="h2 CERMAIL"><h2 id="CERMAIL"$main::kfontsize_h2>お知らせメール配信</h2></div>
登録はまだありません。
メールを配信するには 
<strong><a href="http://aurasoul.mb2.jp/$kindex">ＴＯＰページ</a> &gt; 好きな掲示板 &gt; 
好きな記事 &gt; <a href="http://aurasoul.mb2.jp/_qst/?mode=cermail&amp;no=2287">「お知らせメール」</a></strong> の順でリンクを辿って下さい。
$domain_list
);
}


}


#-------------------------------------------------
# マイ設定変更時のエラー
#-------------------------------------------------

sub my_error{

my($error) = @_;


my $print = <<"EOM";
$error
<a href="?mode=my$backurl_query_enc">戻る</a>
EOM

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# これまでの成績を取得
#-----------------------------------------------------------
sub get_myrecord{

my($domain_list) = &main_mypage_domainlist("RECORD");

if($csoumoji && $csoutoukou >= 1){ $heikin = int($csoumoji / $csoutoukou); }

$csoumoji = int($csoumoji);

$hyo_heikin="もう少し頑張りましょう";

if($heikin > 500) { $hyo_heikin = 'エクセレント！'; }
elsif($heikin > 250) { $hyo_heikin = 'なかなか素晴らしい'; }
elsif($heikin > 100) { $hyo_heikin = '良い出来です'; }
elsif($heikin > 50) { $hyo_heikin = '普通です'; }

$myrecord .= qq(<div class="h2 RECORD"><h2 id ="RECORD"$main::kfontsize_h2>これまでの成績</h2></div>);

# リンク
my $ranking_link = qq(	<span class="guide">※アカウントに<a href="${auth_url}">ログイン</a>(または新規登録)すると、<a href="/_main/rankgold-p-1.html">ランキング</a> に参加できます。</span> );
if($idcheck){ $ranking_link = qq( &lt; <a href="/_main/rankgold-p-1.html">→ランキング</a> &gt;); }

# クッキーがあったら、投稿情報を表示
if($csoumoji){
$myrecord .= qq(
<ul>
<li>金貨： <strong class="red">$cgold枚</strong> $ranking_link</li>
<li>書き込み： $csoutoukou回</li>
<li>総文字数： $csoumoji \文\字</li>
<li>文字数平均： $heikin \文\字  （$hyo_heikin）</li>
</ul>
);
}

#クッキーない場合
else{ $myrecord .= qq(投稿データはありません。);}

$myrecord .= qq($domain_list);

}



#-----------------------------------------------------------
# ドメイン切り替えリンクを表示
#-----------------------------------------------------------
sub main_mypage_domainlist{

# 宣言
my($type) = @_;
my($line,$i,$domain,$movetype);
our($server_domain,$backurl_query_enc,$backurl_link,@domains,%in);

	# 整形
	if($type){ $movetype = "#$type"; }


	# ドメイン引数を定義
	if($in{'domain'}){ $domain = $in{'domain'}; }
	else{ $domain = $server_domain; }

	# ドメインを展開
	foreach(@domains){
		$i++;
		if($i > 1){ $line	 .= qq( - ); }
			if($_ eq $server_domain){ $line .= qq(<strong>$_</strong>); }
			else{ $line .= qq(<a href="http://$_/_main/?mode=my&amp;domain=$domain$backurl_query_enc$movetype">$_</a>); }
	}

	# 整形
	#  class="$type " # CCC
	if($backurl){ $line = qq(<div class="domain_list right">$backurl_link - $line</div>); }
	else{ $line = qq(<div class="domain_list right">$line</div>); }

return($line);

}



#-----------------------------------------------------------
# クッキーの要素リスト
#-----------------------------------------------------------
sub main_mypage_cookielist{

my($my_account) = Mebius::my_account();
my ($self);

# 管理者にデータ表示
if($my_account->{'master_flag'}){
$self = qq(
<div class="h2"><h2$main::kfontsize_h2>Cookie</h2></div>
<div style="color:#080;line-height:1.4em;">
筆名： $cnam | 
投稿後ジャンプ： $cposted | 
ＩＤの素： $cpwd | 
文字色： $ccolor | 
記事アップ： $cup | 
セット回数： $ccount | 
新規投稿時刻： $cnew_time | 
レス時刻： $cres_time | 
金貨： $cgold | 
総文字数： $csoumoji | 
投稿回数： $csoutoukou | 
文字サイズ： $cfontsize | 
フォロー： $cfollow | 
閲覧： $cview | 
管理番号： $cnumber | 
投稿履歴： $crireki | 
レス省略： $ccut | 
メモ時間： $cmemo_time | 
アカウント： $caccount | 
パスワード： $cpass | 
削除時間： $cdelres | 
トップ掲載： $cnews | 
年齢： $cage | 
メールアドレス： $cemail | 
秘密： $csecret
</div>
);
}

$self;

}

#-------------------------------------------------
# URLエンコード
#-------------------------------------------------
sub url_enc {
local($_) = @_;

s/(\W)/'%' . unpack('H2', $1)/eg;
s/\s/+/g;
$_;
}

#-----------------------------------------------------------
# 投稿履歴の操作
#-----------------------------------------------------------
sub control_new_system_history_mypage{
my $self = shift;
my $history = new Mebius::History;
$history->query_to_control_history();
}


#-----------------------------------------------------------
# 投稿履歴の操作
#-----------------------------------------------------------
sub control_history_mypage{

# 宣言
my($plustype);

	# 扱うファイルを定義
	if($main::in{'target_file'} eq "crap"){ $plustype .= qq( Crap-file); }
	elsif($main::in{'target_file'} eq "res"){ $plustype .= qq( Res-file); }
	elsif($main::in{'target_file'} eq "check"){ $plustype .= qq( Check-file); }
	else{ main::error("操作したい対象を選んでください。"); }

		require "${int_dir}part_history.pl";

		&get_reshistory("ACCOUNT Control-history RENEW File-check-return My-file $plustype");
		&get_reshistory("CNUMBER Control-history RENEW File-check-return My-file $plustype");
		&get_reshistory("KACCESS_ONE Control-history RENEW File-check-return My-file $plustype");
		&get_reshistory("HOST Control-history RENEW File-check-return My-file $plustype");

#Mebius::Redirect("My-server-domain","${main::main_url}?mode=my");

}



#-----------------------------------------------------------
# 変更処理
#-----------------------------------------------------------
sub mysubmit{

# 宣言
my($sendmail_flag,$error_flag,%address,%renew_address,%set_cookie);
my($my_cookie) = Mebius::my_cookie_main_logined();
our(%in);

# ID を定義
my($encid) = main::id();

	# ●メールアドレスを定義
	if($main::in{'cemail'}){

		# メールの書式をチェック
		Mebius::mail_format("Error-view",$main::in{'cemail'});

		# メルアドファイルを取得
		(%address) = Mebius::Email::address_file("Get-hash-detail Mypage",$main::in{'cemail'});

			# ▼メールの配信可能時間
			if($address{'myaddress_flag'}){

				# 局所化
				my $start = $main::in{'email_allow_hour_start'};
				my $end = $main::in{'email_allow_hour_end'};

				# 配信許可時間帯を設定
				if(defined($start) && defined($end)){
						if($start =~ /\D/){ main::error("メール配信時間帯には、半角数字を指定してください。"); }
						if($end =~ /\D/){ main::error("メール配信時間帯には、半角数字を指定してください。"); }
						if($start > 24){ main::error("メール配信時間帯は、24時より大きくは出来ません。"); }
						if($end > 24){ main::error("メール配信時間帯は、24時より大きくは出来ません。"); }
						if($start > $end){ main::error("メール配信の開始時間は、終了時間以前に設定してください。"); }
					$renew_address{'allow_hour'} = qq($start-$end);
				}
			}

		# 認証用メールを配信する場合
		if($main::in{'send_cermail'} eq "send"){
			require "${int_dir}part_cermail.pl";
			($error_flag,$cermail_message) = Mebius::Email::SendCermail(undef,$main::in{'cemail'});
				if($error_flag){ main::error($error_flag); } 
		}

	}

	# メルアドをCookieにセット
	if(exists $in{'cemail'}){
		$set_cookie{'email'} = $in{'cemail'};
	}

	# 認証メッセージを整形
	if($cermail_message){
		$cermail_message = qq(<hr$main::xclose>$cermail_message);
	}

	# 筆名判定
	if(length($in{'cnam'}) > $maxnam*2){ &my_error("筆名が長すぎます。"); }

	# セットするクッキーを定義
	if(exists $in{'cfontsize'}){
		$set_cookie{'font_size'} = $in{'cfontsize'};
		$set_cookie{'font_size'} =~ s/\D//g;
	}

	# 筆名
	if(exists $in{'cnam'}){
		$set_cookie{'name'} = $in{'cnam'};
	}

	# 携帯版の文章カット
	if(exists $in{'ccut'}){
		$set_cookie{'omit_text'} = $in{'ccut'};
		$set_cookie{'omit_text'} =~ s/[^0-9\.]//g;
	}

	# 年齢設定
	if(exists $in{'cage'}){
		$set_cookie{'age'} = $in{'cage'};
		$set_cookie{'age'} =~ s/\D//g;
	}

	# 投稿後のジャンプ
	if(exists $in{'cposted'}){
		$set_cookie{'refresh_second'} = $in{'cposted'};
		$set_cookie{'refresh_second'} =~ s/\W//;g
	}

	# 端末タイプ
	if(exists $in{'cdevice_type'}){
			if($in{'cdevice_type'} eq "Auto"){ $set_cookie{'device_type'} = ""; }
			else{ $set_cookie{'device_type'} = $in{'cdevice_type'}; }
	}

	# お絵かき画像表示の有無
	#if(exists $in{'cimage_link'}){
	#	$cimage_link = $in{'cimage_link'};
	#	$cimage_link =~ s/\W//;g
	#}

	# ＩＤフィルタ
	if(exists $in{'cfillter_id'}){
		my($i,$max_fillter) = (0,5);
		$encid_hit = $encid;
		$encid_hit =~ s/^([A-Z]+(=|-))//g;
			foreach(split(/\s|　/,$in{'cfillter_id'})){
				($_) = Mebius::Text::Alfabet("All-to-half",$_);
				$_ =~ s/★//g;
				$_ =~ s/^([A-Za-z0-9]+(=|-))//g;	# 入力内容から SOFTBANK= など、端末記号を削除
				$_ =~ s/((_|=|-)[A-Za-z0-9\.\/]+$)//g;	# 入力内容から 終末記号を削除
					if($_ =~ /([^\w\/\-\.])/){ main::error("IDフィルタ ( $_ ) の中に使えない文字 ( $1 ) が含まれています。"); }
					if($_ eq $encid || $encid =~ /^${_}_/){ main::error("自分自身 ( $_ ) はフィルタ設定できません。"); }
				$i++;
				$set_cookie{'id_fillter'} .= qq($_ );
			}
		if($i > $max_fillter){ main::error("ＩＤフィルタは、最大$max_fillter個までです。新しく追加するには、他のフィルタを削除してください。"); }
		$set_cookie{'id_fillter'} =~ s/\s+$//g;
		if(length $set_cookie{'id_fillter'}> $max_fillter*15){ main::error("ＩＤフィルタが長すぎます。"); }
	}

	# アカウントフィルタ
	if(exists $in{'cfillter_account'}){
		my($i,$max_fillter) = (0,5);
			foreach(split(/\s|　/,$in{'cfillter_account'})){
				($_) = Mebius::Text::Alfabet("All-to-half",$_);
				$_ = lc $_;
					if($_ =~ /([^a-z0-9])/){ main::error("アカウントフィルタ ( $_ ) の中に、使えない文字 ( $1 ) が含まれています。"); }
					if($_ eq $main::pmfile){ main::error("自分自身 ( $_ ) はフィルタ設定できません。"); }
				$i++;
				$set_cookie{'account_fillter'} .= qq($_ );
			}
		if($i > $max_fillter){ main::error("アカウントフィルタは、最大$max_fillter個までです。新しく追加するには、他のフィルタを削除してください。"); }
		$set_cookie{'account_fillter'} =~ s/\s+$//g;
		if(length $set_cookie{'account_fillter'} > $max_fillter*10){ main::error("アカウントフィルタが長すぎます。"); }
	}

	# 記録用
	#if($cfillter_account || $cfillter_id){ main::access_log("Fillter-mypage","ＩＤフィルタ：$cfillter_id / アカウントフィルタ： $cfillter_account "); }

	# 投稿履歴をオフに
	if($in{'record_crireki'} eq "off"){
		$set_cookie{'use_history'} = "off";
	}

	# 投稿履歴をリセット
	elsif($in{'record_crireki'} eq "reset"){
		$set_cookie{'use_history'} = "off";
		require "${int_dir}part_history.pl";
		&get_reshistory("ACCOUNT UNLINK RENEW File-check-return My-file");
		&get_reshistory("CNUMBER UNLINK RENEW File-check-return My-file");
		&get_reshistory("KACCESS_ONE UNLINK RENEW File-check-return My-file");
		&get_reshistory("HOST UNLINK RENEW File-check-return My-file");
	}

	# 投稿履歴を再開
	elsif($in{'record_crireki'} eq "start" && $my_cookie->{'use_history'} eq "off"){ $set_cookie{'use_history'} = ""; }

	if($in{'cfollow'} eq "off"){ $set_cookie{'follow'} = "off";  }
	if($my_cookie->{'follow'} eq "off" && $in{'cfollow'} eq "on"){ $set_cookie{'follow'} = ""; }

	# トリップありの場合
	if(exists $in{'ctrip'}){
			if($in{'ctrip'}){ $set_cookie{'name'} = "$in{'cnam'}#$in{'ctrip'}"; }
			else{ $set_cookie{'name'} = $in{'cnam'}; }
			if(length($in{'ctrip'}) > 20){ &my_error("トリップ元の文字列が長すぎます。"); }
			if($in{'ctrip'} && length($in{'ctrip'}) <= 1){ &my_error("トリップ元の文字列が短すぎます。"); }
			if($in{'cnam'} eq $in{'ctrip'} && $in{'cnam'} && $in{'ctrip'}){ &my_error("筆名とトリップの素は同じに出来ません。"); }
	}

# クッキーセットを実行
Mebius::Cookie::set_main(\%set_cookie,{ SaveToFile => 1 });

	# メルアド単体ファイルを更新する場合
	if(%renew_address){
		Mebius::Email::address_file("Renew-myaccess",$main::in{'cemail'},%renew_address);
	}

# ジャンプ先を定義
	my($backurl_encode) = Mebius::Encode(undef,$in{'backurl'});
$jump_url = "$script?mode=settings&amp;backurl=$backurl_encoded";

	if($backurl && $in{'backurl_on'}){ $jump_url = $backurl; }
	if($in{'backurl'} eq ""){
		$jump_url = "$script?mode=settings&amp;backurl=$backurl_encoded";
	}

if($cermail_message){ $jump_sec = 60*60; }
else{ $jump_sec = 1; }

	# リダイレクトする場合
	if($main::in{'redirect'} && $backurl){
		Mebius::Redirect(undef,$backurl);
	}


# HTML
my $print = <<"EOM";
マイページの設定を変更しました。（<a href="$jump_url">→戻る</a>）<br$main::xclose>
$send_text1$return$after_text1
$cermail_message
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;

