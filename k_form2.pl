
package main;
use Mebius::BBS::Form;

#-----------------------------------------------------------
# 携帯版 投稿フォーム
#-----------------------------------------------------------
sub bbs_thread_form_mobile{

# 宣言
my($job) = @_;
my($submit,$tcount,$next_resnumber,$print);
my($my_account) = Mebius::my_account();
our($time,%in,$last_res,$concept,$stop_regist_mode);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);



# 送信用、現在のレス番
	if($in{'resnum'}){ $next_resnumber = $in{'resnum'}; }
	else{ $next_resnumber = $res + 1; }

$kflag = 1;

# 携帯版　新規投稿の場合
if ($job eq "new") { $print .= "新規投稿"; }

# 削除/ロック/警告理由を取得
my($alert_person,$alert_date,$alert_lasttime,$alert_reason) = split(/=/,$d_delman);
my($alert_reason_text);
	if($alert_reason){
		require "${int_dir}part_delreason.pl";
		($alert_reason_text) = &delreason($alert_reason,undef,$sub,$head_title);
			if($alert_reason_text){ $alert_reason_text = qq(<span style="color:#f00;">$alert_reason_text</span>); }
	}

# ロック判定用の予備処理
require "${main::int_dir}part_thread_status.pl";
my($alert_line) = &thread_status_lock("LOCK DESKTOP Mobile-view",$d_delman,$lock_end_time);


	# 投稿フォームを表示しない場合
	if($newwait_flag) { $print .= "<hr$xclose>新規投稿は、あと $zan_day日$zan_hour時間$zan_minute分 待ってください。\n"; $return = 1; } 
	elsif ($key eq '0' && $alert_line) {
		$print .= qq(<hr$xclose$alert_line\n);
		$return = 1;
	}
	elsif ($key eq '3') { $print .= "<hr$xclose>この記事は過去ログです。\n"; $return = 1; }
	elsif ($key eq '7') { $print .= "<hr$xclose>この記事は削除予\約中です。一定期間後に、自動的に削除されます。$alert_reason_text\n"; $return = 1; }
	elsif($concept =~ /Not-regist/){  $print .= qq(<hr$xclose>この掲示板は書き込み停止中です。\n); $return = 1; }
	elsif($stop_regist_mode){  $print .= qq(<hr$xclose>現在、投稿を受け付けていません。\n); $return = 1; }
	elsif (($m_max *0.9) < $res) {
		$print .= qq(<hr$xclose>レス$res件/最大$m_max件\n);
			if($m_max <= $res){ $return = 1; }
	}
	elsif ($krule_on) { $return = 1; }


	# 終了
	if($return){ return($print); }

	# 警告
	if ($thread_key =~ /Alert-violation/){
			if($alert_lasttime + 30*24*60*60 >= $main::time){
				$print .= qq(<div style="background:#fbb;$ktextalign_center_in$kborder_top_in">管理者より(重要)</div>);
				$print .= qq($emoji_shift_jis->{'alert'}$alert_reason_text);
				$print .= qq(<br$main::xclose>$emoji_shift_jis->{'alert'}この状態が続く場合、記事をロック/削除させていただく場合があります。);
			}

	}

# 画像添付
if($main::bbs{'concept'} =~ /Upload-mode/){ require "${int_dir}part_upload.pl"; &upload_setup("k"); }

if($rule_text && $job eq "new"){
# ルール書き出し
print"<hr$xclose>■$titleのルール<br$xclose>";
if($concept !~ /DOUBLE-OK/ && $main::bbs{'concept'} !~ /Sousaku-mode/){
print"◎<a href=\"${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6\">新規投稿</a>の前に
<a href=\"${guide_url}%BD%C5%CA%A3%B5%AD%BB%F6\">重複記事</a>がないか<a href=\"kfind.html\">検索</a>してください。<br$xclose>";}
$rule_text =~ s/<br>/<br$xclose>/g;
$rule_text =~ s/<br><br>/<br>/g;
$print .= "$rule_text<br$xclose>";
}


	# ストップモード
	if(Mebius::Switch::stop_bbs()){
		$print .= qq(<div style="color:#f00;border-top:solid 1px #000;">現在、掲示板全体で投稿停止中です。</div>);
		return $print;
	}



# 投稿フォーム
$print .= qq(<form action="$script" method="post"$formtype$sikibetu><div>);


	# 返信フォームの帯
	if($job eq "new"){ $print .= qq(<div style="background:#9f9;text-align:center;$kborder_top_in">新規投稿フォーム</div>); }
	else{
		$print .= qq(<div style="background:#9f9;text-align:center;$kborder_top_in">);
		$print .= qq( $emoji_shift_jis->{'number5'}<a href="#ARESFORM" id="ARESFORM" accesskey="5">返信</a></div>);
	}


# 投稿前の注意

$print .= qq(<div>);

	# ルール表示
	if($job ne "new"){
	if($subtopic_mode){ $print .= qq($emoji_shift_jis->{'exclamation'}本編は<a href="/_$moto/$in{'no'}.html">メイン記事</a>へどうぞ<br$xclose>); }
	elsif($subtopic_link && $subkey ne "0"){ $print .= qq($emoji_shift_jis->{'exclamation'}感想/ｺﾒﾝﾄは<a href="/_sub$moto/$in{'no'}.html"$sub_nofollow>ｻﾌﾞ記事</a>へどうぞ<br$xclose>); }
	}

	if($rule_text && $job eq ""){
	$print .= qq($emoji_shift_jis->{'exclamation'}<a href="${guide_url}%C0%DC%C2%B3%A5%C7%A1%BC%A5%BF">接続データが保存されます</a><br$xclose>);
	$print .= qq($emoji_shift_jis->{'exclamation'}<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">全体ﾙｰﾙ</a>と<a href="krule.html">板ﾙｰﾙ</a>は);
	$print .= qq(<span style="color:#f00;">必読</span>です<br$xclose>
	);
	}



$print .= qq(</div><hr$main::xclose>);


# テキストエリアの初期入力
my $textarea_input = $textarea_first_input;
$textarea_input =~ s/<br>/\n/g;

if ($job ne "new") {  }
elsif ($job eq "new") { 

$print .= "題<input type=\"text\" name=\"sub\" size=\"14\" value=\"$resub\" maxlength=\"50\"$xclose><br$xclose>"; }

# 性表現、暴力表現
if($job eq "new"){ require "${int_dir}part_sexvio.pl"; &sexvio_form(); }

# 入力ボックス
$print .= qq(名<input type="text" name="name" size="12" value="$cnam"$xclose>);

my(@color) = Mebius::Init::Color(undef);
 
# 文字色
$print .= qq(色<select name="color">);
	foreach(@color) {
		my($name,$code) = split(/=/);
			if($code eq $ccolor) { $print .= qq(<option value="$code"$main::parts{'selected'}>$name</option>\n); }
			else { $print .= qq(<option value="$code">$name</option>\n); }
	}
$print .= qq(</select>);

# 入力ボックス
$print .= qq(
<br$xclose><textarea cols="25" rows="5" name="comment">$textarea_input</textarea><br$xclose>
$input_upload
$viocheck$sexcheck
<span style="font-size:small;">
);


my $form_parts = new Mebius::BBS::Form;

	# Up チェックボックス
	if ($job ne "new") {

		$print .= $form_parts->thread_up({ MobileView => 1 , from_encoding => "sjis" });
			#if ($cup != 2) { print"<input type=\"checkbox\" name=\"up\" value=\"1\"$checked$xclose>ｱｯﾌﾟ"; }
			#else{ print"<input type=\"checkbox\" name=\"up\" value=\"1\"$xclose>ｱｯﾌﾟ";}
	}
	else{
		$print .= $form_parts->thread_up({ Hidden => 1 , MobileView => 1 , from_encoding => "sjis" });
			#if ($cup != 2) { print"<input type=\"hidden\" name=\"up\" value=\"1\"$xclose>"; }
	}



	# TOP新着ボックス
	#if($secret_mode){ $print .= qq(<input type="hidden" name="news" value="$cnews"$xclose>); }
	#else{
	#if($cnews eq "2"){ $print .= qq(<input type="checkbox" name="news" value="1"$xclose>新着); }
	#else{ $print .= qq(<input type="checkbox" name="news" value="1"$checked$xclose>新着); }
	#}

	# 履歴の公開
	#$print .= Mebius::BBS::id_history_input_parts({ from_encoding => "sjis" });

	# アカウントへのリンク
	$print .= $form_parts->account_link({ from_encoding => "sjis" , MobileView => 1 });
	$print .= $form_parts->news({ from_encoding => "sjis" , MobileView => 1 });

if ($job ne "new") { $print .= "<input type=\"hidden\" name=\"res\" value=\"$in{'no'}\"$xclose>"; }

$print .= qq(
</span>
<br$main::xclose>
<div style="text-align:right;">
<input type="submit" name="preview" value="*確認" accesskey="*"$xclose>
<input type="submit" value="#送信" accesskey="#"$xclose>
<input type="hidden" name="mode" value="regist"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="k" value="1"$xclose>
<input type="hidden" name="access_time" value="$time"$xclose>
<input type="hidden" name="resnum" value="$next_resnumber"$xclose>
$backurl_input
</div>
</div></form>
);

		return $print;
}


1;
