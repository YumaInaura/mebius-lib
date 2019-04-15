
use strict;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# 編集フォームを独立ページとして表示 
#-----------------------------------------------------------
sub auth_myform_page{

# 宣言
my($type) = @_;
my(%account,$editform);
our(%in,$submode2);

# ファイル定義
(%account) = Mebius::Auth::File("",$in{'account'});

	# 自分のプロフィールページの場合、編集フォームを出す
	if($account{'editor_flag'}){
		if($submode2 eq "detail"){ ($editform) = &auth_myform("Detail",$account{'file'}); }
		else{ ($editform) = &auth_myform("",$account{'file'}); }
	}
	else{ main::error("人の設定フォームです。"); }

# HTML部分
my $print = qq($editform);

main::auth_html_print($print,"SNSの設定",\%account);


exit;


}

#-------------------------------------------------
# 編集フォーム - マイアカウント
#-------------------------------------------------
sub auth_myform{


# 局所化
my($type,$file,$plus_line) = @_;
my(%account,$logout,$valuename,$admin_input,$alert,$flowflag,$h3text,$myform);
my($submit1,$submit2,$text1,$detail_link,$select_vote,$select_crap_diary);
our($css_text,$guide_url,$myadmin_flag,%in,$xclose,$postflag,$sikibetu,$auth_url,$i_trip,$kfontsize_h2,$kflag);


# ファイル定義
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ return(); }

	# SNS停止中
	if($main::stop_mode =~ /SNS/){
		return(qq(現在、SNSは停止中のため、プロフィールは更新できません。));
	}

# アカウントファイルを開く
(%account) = Mebius::Auth::File("Hash Option",$file);


# CSS定義
$css_text .= qq(
.h2_edit{background-color:transparent;border-style:none;margin:0.7em 0em;padding:0em;}
.h3_edit{margin:1em 0em 0.3em 0em;}
.editform{margin-top:0.5em;padding:1.0em 1.0em 1.0em 1.0em;border:solid 1px #f00;line-height:1.6em;}
div.editform_core{line-height:2.2em;margin:1em 0em;}
strong.option{border:solid 1px #00f;background:#eef;padding:0.2em 0.5em;margin-right:0.5em;}
.pinput{width:15em;}
.ptextarea{width:95%;height:300px;line-height:1.4em;}
.alert2{line-height:1.9em;display:inline;color:#f00;background-color:#fff;padding:0.2em 0.3em;border:solid 1px #f00;font-size:90%;margin-right:0.2em;}
div.alert{padding:0.5em;margin:0.5em;background-color:#fff;line-height:1.25em;border:solid 1px #f00;font-size:90%;color:#f00;}
div.error{line-height:1.4em;}
span.mini{font-size:80%;}
div.prev{line-height:1.4em;}
div.detail_link{text-align:right;}
#ERROR{color:#f00;background-color:transparent;border:solid 1px #f00;}
#PREV{color:#00f;background-color:transparent;border:solid 1px #00f;}
);

	# プレビューの場合、パラメータを置換え
	if($postflag){
		$account{'name'} = $in{'name'};
		$account{'mtrip'} = $i_trip;
		$account{'ocomment'} = $in{'ppocomment'};
		$account{'odiary'} = $in{'ppodiary'};
		$account{'osdiary'} = $in{'pposdiary'};
		$account{'orireki'} = $in{'pporireki'};
		$account{'osdiary'} = $in{'pposdiary'};
		$account{'color1'} = $in{'ppcolor1'};
		$account{'color2'} = $in{'ppcolor2'};
		$account{'myurl'} = $in{'myurl'};
		$account{'myurltitle'} = $in{'myurltitle'};
		$account{'ohistory'} = $in{'ohistory'};
		$account{'okr'} = $in{'okr'};
		$account{'allow_vote'} = $in{'allow_vote'};


		if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }
		if($in{'email'} ne ""){ $account{'email'} = $in{'email'}; }
		$account{'prof'} = qq(\n$in{'prof'});
	}


# テキストエリアの改行整形
my $form_prof = $account{'prof'};
$form_prof =~ s/<br>/\n/g;

# トリップ元の文字列
$valuename = $account{'name'};
if($account{'mtrip'}){ $valuename = qq($valuename#$account{'mtrip'}); }

# セレクトボックス
my($select_admin,$select_rireki,$select_kr);
my($select_diary) = select_diary("",$account{'odiary'});
my($select_comment) = select_comment("",$account{'ocomment'});
my($select_osdiary) = select_osdiary("",$account{'osdiary'},$account{'level'});
my($select_view_last_access) = select_last_access_auth(undef,%account);
my($select_color1) = select_color1("",$account{'color1'});
my($select_color2) = select_color2("",$account{'color2'});
#my($input_email) = input_email("",$file,$account{'email'},$account{'mlpass'});
my $input_email = new_input_email_area(__PACKAGE__,\%account);
my($select_mylist); # = &myurl_form_auth("",$account{'myurl'},$account{'myurltitle'});
my($select_birthday) = select_birthday_auth(undef,%account);
my($select_message) = select_message_auth(undef,%account);
my($select_catch_mail) = select_catch_mail_auth(undef,%account);

	# 詳細設定
	if($type =~ /Detail/){
		($select_rireki) = &select_rireki("",$account{'orireki'},$account{'ohistory'});
		($select_kr) = &select_kr("",$file,%account);
		($select_vote) = &select_vote_authmyform("",$account{'allow_vote'});
		($select_crap_diary) = &select_crap_diary_authmyform(undef,%account);
	}

if($myadmin_flag >= 5){ ($select_admin) = &select_admin("",%account); }

# 注釈
$text1 = qq( <span class="mini"> … メビウスリングでの活動場所などを記入してください。
			 <span class="red">( 個人情報・メルアド掲載、恋人募集 などは禁止です。<a href="${guide_url}" target="_blank" class="blank">[ルール]</a></span> )</span> );

# 管理者の場合
if($myadmin_flag){ $admin_input = qq(<input type="hidden" name="account" value="$file"$xclose>); }

$alert = qq(
<div class="alert">＊注意…プロフィールは全ての人に公開され、検索エンジンにも登録されます。電話番号、メールアドレス、本名、住所など個人情報は絶対に書き込まないで下さい。</div>);

	# 送信ボタン（プレビュー時）
	if($kflag){
$submit1 = $submit2 = qq(
<input type="submit" name="preview" value="確認"$xclose>
<input type="submit" value="送信" class="isubmit"$xclose>
);
	}else{ 
$submit1 = $submit2 = qq(
<input type="submit" name="preview" value="この内容でプレビューする" class="ipreview"$xclose>
<input type="submit" value="この内容で本設定する" class="isubmit"$xclose>
);
	}


	# ● 詳細リンクなど
	{

		$detail_link .= qq(<div class="detail_link">);

		# パスワード再設定フォームへのリンク
		$detail_link .= qq(<a href="./?mode=aview-remain&type=reset_password_view&input_type=password">→パスワード再設定</a>\n);
		$detail_link .= qq(<a href="./?mode=aview-remain&type=reset_remain_email_view&input_type=password">→リメインアドレスの設定</a>\n);

		# 詳細設定へのリンク
		if($type !~ /Detail/){
			$detail_link .= qq(<a href="$auth_url$file/edit-detail#EDIT" style="color:#777;font-size:medium;">→詳細設定へ</a>\n);
		}
		$detail_link .= qq(</div>);
	}

# 詳細
my $finput_detail = $in{'detail'};
if($type =~ /Detail/){ $finput_detail = "1"; }

# フォームを出力
$myform .= <<"EOM";
<form action="$auth_url" method="post"$sikibetu>
<div>
$plus_line
<h2 id="EDIT"$kfontsize_h2>設定変更</h2>
<div class="editform">
$submit1
<div class="editform_core">
<strong class="option">筆名：</strong>
<input type="text" name="name" value="$valuename" class="pinput"$xclose>
$input_email
$select_catch_mail
$select_birthday
<strong class="option">プロフィール$text1：</strong><br$main::xclose>
<textarea name="prof" class="ptextarea" cols="25" rows="5">$form_prof</textarea><br$xclose>
$alert
$select_color1
$select_color2
<div>
<strong class="option">許可：</strong>
$select_view_last_access
$select_message
$select_diary
$select_comment
$select_osdiary
</div>

$select_mylist
$select_rireki
$select_kr
$select_vote
$select_crap_diary
</div>
$submit2
<input type="hidden" name="mode" value="editprof"$xclose>
<input type="hidden" name="detail" value="$finput_detail"$xclose>
$admin_input $detail_link
</div>
</div>
</form>
$select_admin
EOM
	
return($myform);

}



#-----------------------------------------------------------
# 誕生日の設定
#-----------------------------------------------------------
sub select_birthday_auth{

# 宣言
my($type,%account) = @_;
my($line,$selected_not_open,$selected_friend_open);

# 各種リターン
if(!$main::thisyear){ return(); }

# 整形
$line .= qq(<strong class="option">誕生日：</strong> );

	# ●年の展開
	if($account{'birthday_year'} && !$main::myadmin_flag){
		$line .= qq($account{'birthday_year'}年 );
	}
	else{
		my(@years);
		$line .= qq(<select name="birthday_year">\n);
			$line .= qq(<option value="">未選択</option>\n);
				for($main::thisyear - 120 .. $main::thisyear - 10){
					push(@years,$_);
				}
			@years = sort { $b <=> $a } @years;
				foreach(@years){
					my $selected = $main::parts{'selected'} if($main::in{'birthday_year'} eq $_ || $account{'birthday_year'} eq $_);
					$line .= qq(<option value="$_"$selected>$_</option>\n);
				}
		$line .= qq(</select> 年\n);
	}

	# ●月の展開
	if($account{'birthday_month'} && !$main::myadmin_flag){
		$line .= qq($account{'birthday_month'}月 );
	}
	else{
		$line .= qq(<select name="birthday_month">\n);
			$line .= qq(<option value="">未選択</option>\n);
				for(1 .. 12){
					my $selected = $main::parts{'selected'} if($main::in{'birthday_month'} eq $_ || $account{'birthday_month'} eq $_);
					$line .= qq(<option value="$_"$selected>$_</option>\n);
				}
		$line .= qq(</select> 月\n);
	}

	
	# ●日の展開	# ●年の展開
	if($account{'birthday_day'} && !$main::myadmin_flag){
		$line .= qq($account{'birthday_day'}日 );
	}
	else{
		$line .= qq(<select name="birthday_day">\n);
			$line .= qq(<option value="">未選択</option>\n);
				for(1 .. 31){
					my $selected = $main::parts{'selected'} if($main::in{'birthday_day'} eq $_ || $account{'birthday_day'} eq $_);
					$line .= qq(<option value="$_"$selected>$_</option>\n);
				}
		$line .= qq(</select> 日\n);
	}

	# 公開設定の初期チェックを定義
	if($account{'birthday_concept'} =~ /Not-open/ || $main::in{'birthday_concept_open'} eq "Not-open"){
		$selected_not_open = $main::parts{'selected'};
	}
	elsif($account{'birthday_concept'} =~ /Friend-open/){
		$selected_friend_open = $main::parts{'selected'};
	}
	else{
		$selected_friend_open = $main::parts{'selected'};
	}

	#$line .= qq(誕生日の公開： \n);
	$line .= qq(<select name="birthday_concept_open">\n);
	$line .= qq(<option value="Not-open"$selected_not_open>誕生日は非公開</option>\n);
	$line .= qq(<option value="Friend-open"$selected_friend_open>誕生日は$main::friend_tagまで公開</option>\n);
	$line .= qq(</select>\n);

	if(!$account{'birthday_year'} || $main::alocal_mode){
		$line .= qq(<span style="color:#080;" class="size90">※非公開設定にしても、おおまかな年齢区分は公開される場合があります。</span>\n);
	}

	# 大人マーク
	if($main::alocal_mode){ $line .= qq( 大人： $account{'adult_flag'}); }

$line = qq(<div>$line</div>);


return($line);

}

#-----------------------------------------------------------
# メッセージボックスの利用
#-----------------------------------------------------------
sub select_message_auth{

# 宣言
my($type,%account) = @_;
my($line,$selected_use,$selected_friend_only,$selected_not_use,$selected_deny_use);

# メールが利用できない場合
if(!$account{'allow_message_status'}){ return(); }

	# 初期チェックを定義
	if($main::postflag){
			if($main::in{'allow_message'} eq "Use"){ $selected_use = $main::parts{'selected'}; }
			if($main::in{'allow_message'} eq "Friend-only"){ $selected_friend_only = $main::parts{'selected'}; }
			if($main::in{'allow_message'} eq "Not-use"){ $selected_not_use = $main::parts{'selected'}; }
			if($main::in{'allow_message'} eq "Deny-use"){ $selected_deny_use = $main::parts{'selected'}; }
	}
	else{
			if($account{'allow_message'} eq "Use" || $account{'allow_message'} eq ""){ $selected_use = $main::parts{'selected'}; }
			if($account{'allow_message'} eq "Friend-only"){ $selected_friend_only = $main::parts{'selected'}; }
			if($account{'allow_message'} eq "Not-use"){ $selected_not_use = $main::parts{'selected'}; }
			if($account{'allow_message'} eq "Deny-use"){ $selected_deny_use = $main::parts{'selected'}; }
	}

# 定義
$line .= qq(メッセージ： );
$line .= qq(<select name="allow_message">);
$line .= qq(<option value="Use"$selected_use>利用する - 全メンバー</option>\n);
$line .= qq(<option value="Friend-only"$selected_friend_only>利用する - $main::friend_tagのみ</option>\n);
$line .= qq(<option value="Not-use"$selected_not_use>利用しない</option>\n);
	if($main::myadmin_flag){
		$line .= qq(<option value="Deny-use"$selected_deny_use>利用禁止(管理者設定)</option>\n);
	}

$line .= qq(</select>);

return($line);


}

#-----------------------------------------------------------
# お知らせメールの受信設定
#-----------------------------------------------------------
sub select_catch_mail_auth{

# 宣言
my($type,%account) = @_;
my($line);
my($selected_message_catch,$selected_message_not_catch);
my($selected_resdiary_catch,$selected_resdiary_not_catch);
my($selected_comment_catch,$selected_comment_not_catch);
my($selected_etc_catch,$selected_etc_not_catch);

	# メールが認証されていない場合はリターン
	if(!$account{'remain_email'}){ return(); }

	#● メールの受信設定 - メッセージ
	if($account{'allow_message_flag'}){
			if($main::in{'catch_mail_message'} eq "Not-catch" || (!$main::postflag && $account{'catch_mail_message'} eq "Not-catch")){
				$selected_message_not_catch = $main::parts{'selected'};
			}
			else{
				$selected_message_catch = $main::parts{'selected'};
			}
		$line .= qq(<select name="catch_mail_message">\n);
		$line .= qq(<option value="Catch"$selected_message_catch>メッセージ - 受信する</option>\n);
		$line .= qq(<option value="Not-catch"$selected_message_not_catch>メッセージ - 受信しない</option>\n);
		$line .= qq(</select>\n);
	}

	#● メールの受信設定 - 日記へのレス
	if($main::in{'catch_mail_resdiary'} eq "Not-catch" || (!$main::postflag && $account{'catch_mail_resdiary'} eq "Not-catch")){
		$selected_resdiary_not_catch = $main::parts{'selected'};
	}
	else{
		$selected_resdiary_catch = $main::parts{'selected'};
	}
	$line .= qq(<select name="catch_mail_resdiary">\n);
	$line .= qq(<option value="Catch"$selected_resdiary_catch>日記へのレス - 受信する</option>\n);
	$line .= qq(<option value="Not-catch"$selected_resdiary_not_catch>日記へのレス - 受信しない</option>\n);
	$line .= qq(</select>\n);


	#● メールの受信設定 - 伝言板への書き込み ( 初期チェックが逆 )
	if($main::in{'catch_mail_comment'} eq "Catch" || (!$main::postflag && $account{'catch_mail_comment'} eq "Catch")){
		$selected_comment_catch = $main::parts{'selected'};
	}
	else{
		$selected_comment_not_catch = $main::parts{'selected'};
	}
	$line .= qq(<select name="catch_mail_comment">\n);
	$line .= qq(<option value="Catch"$selected_comment_catch>伝言板への投稿 - 受信する</option>\n);
	$line .= qq(<option value="Not-catch"$selected_comment_not_catch>伝言板への投稿 - 受信しない</option>\n);
	$line .= qq(</select>\n);

	#● メールの受信設定 - その他
	if($main::in{'catch_mail_etc'} eq "Not-catch" || (!$main::postflag && $account{'catch_mail_etc'} eq "Not-catch")){
		$selected_etc_not_catch = $main::parts{'selected'};
	}
	else{
		$selected_etc_catch = $main::parts{'selected'};
	}
	$line .= qq(<select name="catch_mail_etc">\n);
	$line .= qq(<option value="Catch"$selected_etc_catch>その他 - 受信する</option>\n);
	$line .= qq(<option value="Not-catch"$selected_etc_not_catch>その他 - 受信しない</option>\n);
	$line .= qq(</select>\n);


	# 整形
	if($line){ $line = qq(<div><strong class="option">お知らせメール：</strong> $line</div>); }


return($line);

}

#-------------------------------------------------
# 帯色の指定
#-------------------------------------------------

sub select_color1{

# 宣言
my($type,$color1) = @_;
my($select_color1,@color1);
our($selected);

@color1 = (
"雲=ccc",
"花=faa",
"祭=f9b",
"紅=f97",
"灯=fc7",
"森=7c7",
"林=7d3",
"海=8ca",
"湖=6cc",
"空=acf",
"雷=b9c",
"妖=eae",
"木=c88",
"金=ee3=",
"銅=dd5=",
"光=fd9"
);


$select_color1 .= qq(<strong class="option">色：</strong> 帯：<select name="ppcolor1">);
$select_color1 .= qq(<option value="">普通</option>\n); 

	foreach(@color1){
		my($name,$code) = split(/=/,$_);
		if($code eq $color1){ $select_color1 .= qq(<option value="$code" style="background-color:#$code;"$selected>$name</option>\n); }
		else{ $select_color1 .= qq(<option value="$code" style="background-color:#$code;">$name</option>\n); }
	}

$select_color1 .= qq(</select>);

return($select_color1);

}

#-----------------------------------------------------------
# 文字色の設定
#-----------------------------------------------------------
sub select_color2{

# 宣言
my($type,$color2) = @_;
my($select_color2,@color);
our($selected);

(@color) = Mebius::Init::Color();

$select_color2 .= qq( 日記：<select name="ppcolor2">);

	foreach(@color){
		my($name,$code) = split(/=/,$_);
		$code =~ s/#//g;
			if($code eq $color2){ $select_color2 .= qq(<option value="$code" style="color:#$code;"$selected>$name</option>\n); }
			else{ $select_color2 .= qq(<option value="$code" style="color:#$code;">$name</option>\n); }
	}

$select_color2 .= qq(</select>);

return($select_color2);

}

#-----------------------------------------------------------
# メルアド
#-----------------------------------------------------------
sub new_input_email_area{

my $self = shift;
my $account_data = shift;
my($return);
my $html = new Mebius::HTML;

$return .= qq(<strong class="option">メールアドレス(非公開)：</strong>);
	if($account_data->{'remain_email'}){
		$return .= e($account_data->{'remain_email'});
	} else {
		$return .= qq(登録なし);
	}

$return .= " ( " . $html->href("./?mode=aview-remain&type=reset_remain_email_view&input_type=password","→変更") . " )";

$return;

}


#-------------------------------------------------
# メルアド登録
#-------------------------------------------------
sub input_email{

my($type,$file,$email,$mlpass) = @_;
my($value,$disabled1,$text1,$checkd,$input_email,$checked1);
our(%in,$xclose,$disabled,$checked,$alocal_mode,$auth_url);

$text1 = qq(<div class="alert"><span style="color:#f00;font-size:small;">
＊メールアドレスを入力すると、日記にコメントがあったときなど、お知らせメールが届きます。
ただしイタズラ防止のため、いちど認証用のメールが発行され、接続データなども一緒に送信されます。
</span></div>);

	if($email){
		$value = $email;
		$text1 = qq(<div class="alert">＊認証が済んでいません。設定変更をおこなうとメールが発行されるので、メールボックスを開いて認証作業を完了させてください。</div>);
	}
	if($mlpass){
		$disabled1 = $disabled;
		$text1 = qq(<div class="alert2">認証済み</div>);
	}

	# ローカル用の解除用ＵＲＬ
	if($alocal_mode && $mlpass){
		$text1 .= qq( (<a href="$auth_url?mode=editprof&amp;type=cancel_mail&amp;account=$file&char=$mlpass">→配信メールから解除(Alocal)</a>));
	}

$input_email .= qq(　<strong class="option">メールアドレス(非公開)：</strong>);

if($in{'reset_email'}){ $checked1 = $checked; }
if($disabled1){ $input_email .= qq(<input type="text" name="none" value="$value" class="pinput"$disabled1$xclose> ); }
else{ $input_email .= qq(<input type="text" name="email" value="$value" class="pinput"$xclose> ); }

$input_email .= qq( $text1 );
if($mlpass){ $input_email .= qq( <input type="checkbox" name="reset_email" value="1" id="reset_email"$checked1$xclose><label for="reset_email">メールアドレスを削除</label><br$main::xclose>); }
$input_email .= qq(<input type="hidden" name="certype" value="sns"$xclose>);

return($input_email);

}

#-----------------------------------------------------------
# ログイン時間の表示
#-----------------------------------------------------------
sub select_last_access_auth{

# 宣言
my($type,%account) = @_;
my($line,$selected_open,$selected_not_open,$selected_friend_only);


	# 初期チェック
	if((!$main::postflag && $account{'allow_view_last_access'} eq "Not-open") || $main::in{'allow_view_last_access'} eq "Not-open"){
		$selected_not_open = $main::parts{'selected'};
	}
	elsif((!$main::postflag && $account{'allow_view_last_access'} eq "Friend-only") || $main::in{'allow_view_last_access'} eq "Friend-only"){
		$selected_friend_only = $main::parts{'selected'};
	}
	else{
		$selected_open = $main::parts{'selected'};
	}

# ログイン時間の表示
$line .= qq(ログイン時間： \n);
$line .= qq(<select name="allow_view_last_access">\n);
$line .= qq(<option value="Open"$selected_open>ログインユーザーに表\示</option>\n);
$line .= qq(<option value="Friend-only"$selected_friend_only>$main::friend_tagだけに表\示</option>\n);
$line .= qq(<option value="Not-open"$selected_not_open>表\示しない</option>\n);
$line .= qq(</select>\n);

# リターン
return($line);


}

#-------------------------------------------------
# 日記へのコメント受け付け
#-------------------------------------------------
sub select_diary{

# 局所化
my($type,$odiary) = @_;
my($select0,$select1,$select2,$select_diary);
our($selected);

if($odiary eq "0"){ $select0 = $selected; }
elsif($odiary eq "2"){ $select2 = $selected; }
else{ $select1 = $selected; }

# コメント受付の設定部分
$select_diary .= <<"EOM";
日記：
<select name="ppodiary">
<option value="1"$select1> 全メンバーにコメント許可</option>
<option value="2"$select2> マイメビにコメント許可</option>
<option value="0"$select0> 自分だけにコメント許可</option>
EOM

$select_diary .= qq(</select>);

return($select_diary);

}

#-------------------------------------------------
# 伝言板へのコメント受け付け
#-------------------------------------------------
sub select_comment{

# 局所化
my($type,$ocomment) = @_;
my($select0,$select1,$select2,$select3,$select9,$select_comment);
our($xclose,$selected);

if($ocomment eq "0"){ $select0 = $selected; }
elsif($ocomment eq "2"){ $select2 = $selected; }
elsif($ocomment eq "3"){ $select3 = $selected; }
else{ $select1 = $selected; }

# コメント受付の設定部分
$select_comment .= <<"EOM";
伝言板：
<select name="ppocomment">
<option value="1"$select1> 全メンバーにコメント許可</option>
<option value="2"$select2> マイメビにコメント許可</option>
<option value="0"$select0> 自分だけにコメント許可</option>
<option value="3"$select3> 伝言板を表\示しない</option>
EOM

$select_comment .= qq(</select>);

# 設定の注意
$select_comment .= <<"EOM";
<br$xclose><div class="alert">
＊注意…伝言板は、他メンバーからの削除依頼にも使われます。
基本的に「全メンバーに許可する」を選んでください。
あなたのアカウントでルール違反がないと確信できる場合だけ、
「マイメビにだけ許可する」「自分にだけ許可する」を選んでください。
</div>
EOM

return($select_comment);

}



#-------------------------------------------------
# 日記表示設定のセレクトボックス
#-------------------------------------------------
sub select_osdiary{

# 局所化
my($type,$osdiary,$level) = @_;
my($select0,$select1,$select2,$select_osdiary);
my($parts) = Mebius::Parts::HTML();

	# 権限チェック
	if($level < 1){ return(); }

	# チェック
	if($osdiary eq "0"){ $select0 = $parts->{'selected'}; }
	elsif($osdiary eq "2"){ $select2 = $parts->{'selected'}; }
	else{ $select1 = $parts->{'selected'}; }

# コメント受付の設定部分
$select_osdiary .= <<"EOM";
日記閲覧：
<select name="pposdiary">
<option value="1"$select1> 全メンバーに表\示する</option>
<option value="2"$select2> マイメビだけに表\示する</option>
<option value="0"$select0> 自分だけに表\示する</option>
EOM

$select_osdiary .= qq(</select>);

return($select_osdiary);

}

#-----------------------------------------------------------
# 猫の利用
#-----------------------------------------------------------
sub select_vote_authmyform{

# 局所化
my($type,$allow_vote) = @_;
my($line,$select_not,$select_use);
our($selected);

	# 選択
	if($allow_vote eq "not-use"){ $select_not = $selected; }
	else{ $select_use = $selected; }

# コメント受付の設定部分
$line .= qq(
<select name="allow_vote">
<option value="use-open"$select_use>猫を受け取る</option>
<option value="not-use"$select_not>猫を受け取らない</option>
);

$line .= qq(</select>);

# リターン
return($line);

}


#-----------------------------------------------------------
# 猫の利用
#-----------------------------------------------------------
sub select_crap_diary_authmyform{

# 局所化
my($type,%account) = @_;
my($line,$select_not,$select_use);

	# 選択
	if($account{'allow_crap_diary'} eq "Deny" || ($main::in{'allow_crap_diary'} eq "Deny" && $main::postflag)){ $select_not = $main::parts{'selected'}; }
	else{ $select_use = $main::parts{'selected'}; }

# コメント受付の設定部分
$line .= qq(
<select name="allow_crap_diary">
<option value="Allow"$select_use>日記へのいいね！を許可</option>
<option value="Deny"$select_not>日記へのいいね！を拒否</option>
);

$line .= qq(</select>);

# リターン
return($line);

}


#-------------------------------------------------
# 投稿履歴表示のセレクトボックス
#-------------------------------------------------
sub select_rireki{

# 局所化
my($type,$orireki,$ohistory) = @_;
my($select0,$select1,$select2,$select_rireki);
my($bselect_use_open,$bselect_use_close,$bselect_not_use);
our($auth_url,$selected);

# 選択
if($orireki eq "0"){ $select0 = $selected; }
else{ $select1 = $selected; }

# コメント受付の設定部分
$select_rireki .= <<"EOM";
<br><br><strong class="option">詳細：</strong>
<select name="pporireki">
<option value="1"$select1>掲示板の投稿履歴を使う</option>
<option value="0"$select0> 掲示板の投稿履歴を使わない</option>
EOM
$select_rireki .= qq(</select>);

# SNSの行動履歴
if($ohistory eq "not-use"){ $bselect_not_use = $selected; }
elsif($ohistory eq "use-close"){ $bselect_use_close = $selected; }
else{ $bselect_use_open = $selected; }

#<option value="not-use"$bselect_not_use> SNSの行動履歴を使わない</option>

# コメント受付の設定部分
$select_rireki .= qq(
<select name="ohistory">
<option value="use-open"$bselect_use_open>SNSの行動履歴を使う(公開)</option>
<option value="use-close"$bselect_use_close>SNSの行動履歴を使う(非公開)</option>
</select>
);


return($select_rireki);

}

#-------------------------------------------------
# 投稿履歴表示のセレクトボックス
#-------------------------------------------------
sub select_kr{

# 局所化
my($type,$file,%account) = @_;
my($select_not_use,$select_use_open,$line);
our($selected);

# 選択
if($account{'okr'} eq "not-use"){ $select_not_use = $selected; }
else{ $select_use_open = $selected; }

# コメント受付の設定部分
$line .= qq(
<select name="okr">
<option value="use-open"$select_use_open>関連リンクを使う</option>
<option value="not-use"$select_not_use>関連リンクを使わない（広告表\示）</option>
</select>
);

return($line);

}

#-------------------------------------------------
# 管理者のみの設定フォーム
#-------------------------------------------------
sub select_admin{

# 局所化
my($type,%account) = @_;
my($unblock_line,$unblock_date);
my($select_admin,$selected_nolimit_account_lock,$period_line);
our($int_dir,$auth_url,%in);

# 取り込み処理
require "${int_dir}part_delreason.pl";
require "${main::int_dir}auth_edit.pl";

# 解除日の取得
$unblock_line .= qq(<select name="ppblocktime">);

	# 既に期限付き制限されている場合
	if($account{'blocktime'}){
		$unblock_date = gettime_unblock($account{'blocktime'});
		$unblock_line .= qq(<option value="$account{'blocktime'}">$unblock_date</option>\n);
	}


	# 無期限アカウントロックの場合
	if($account{'key'} eq "2" && !$account{'blocktime'}){
		$selected_nolimit_account_lock = $main::parts{'selected'};
	}


$unblock_line .= qq(<option value="none">なし</option>\n);
$unblock_line .= qq(<option value="forever"$selected_nolimit_account_lock>無期限</option>\n);

my($option_deny_select) = shift_jis(Mebius::Reason::get_select_denyperiod()); # part_delreason.pl から
$unblock_line .= qq($option_deny_select);
$unblock_line .= qq(</select>);

# 警告/削除理由フォーム
my($select_reason) = shift_jis(Mebius::Reason::get_select_reason($account{'reason'},"ACCOUNT"));

$select_admin .= qq(
<h2 id="BASEEDIT" class="h2_edit">管理設定フォーム</h2>
<form action="$auth_url" method="post">
<div>
キー<br><input type="text" name="ppkey" value="$account{'key'}">
警告 <select name="ppreason">$select_reason</select> 解除日 $unblock_line);

$select_admin .= qq(<div class="margin">);

	# 前回のロック期間
	if($account{'last_locked_period'}){
		my($how_locked) = Mebius::SplitTime("Not-get-second Not-get-minute Not-get-hour",$account{'last_locked_period'});
		$period_line .= qq( │ 前回のロック期間： $how_locked);
		my($how_locked_all) = Mebius::SplitTime("Not-get-second Not-get-minute Not-get-hour",$account{'all_locked_period'});
		$period_line .= qq( │ 全ロック期間： $how_locked_all);
	}

	# 最終管理時刻
	if($account{'adlasttime'}){ 
		my(%time) = Mebius::Getdate("Get-hash",$account{'adlasttime'});
		$select_admin .= qq(　最終管理： $time{'date'} │ ロック回数： $account{'account_locked_count'} $period_line);
		$select_admin .= qq( │ 警告回数: $account{'alert_count'} );
	}

$select_admin .= qq(</div>);

$select_admin .= qq(
<br>
レベル１（秘密会員）<br> <input type="text" name="pplevel" value="$account{'level'}"><br>
レベル２（ＳＰ会員）<br> <input type="text" name="pplevel2" value="$account{'level2'}"><br>
チャット<br> <input type="text" name="ppchat" value="$account{'chat'}"><br>
登録ＵＲＬ<br> <input type="text" name="ppsurl" value="$account{'surl'}"><br>
管理者<br> <input type="text" name="ppadmin" value="$account{'admin'}"><br>
<br><br>
<input type="submit" value="この内容で管理者設定する">
<input type="hidden" name="mode" value="baseedit">
<input type="hidden" name="account" value="$in{'account'}">
</div>
</form>
);

return($select_admin);

}

#-----------------------------------------------------------
# お気に入り記事の登録
#-----------------------------------------------------------
sub myurl_form_auth{

# 宣言
my($type,$myurl,$myurltitle) = @_;
my($line);

# URL設定がない場合
if($myurl eq ""){ $myurl = qq(http://); }

# 定義
$line = qq(
<strong class="option">マイＵＲＬ：</strong>
URL <input type="text" name="myurl" value="$myurl">
タイトル <input type="text" name="myurltitle" value="$myurltitle">
<span class="guide">*許可URL限定、SNS以外。</span>
);

# リターン
return($line);

}

#-----------------------------------------------------------
# 解除日の日にちリスト取得
#-----------------------------------------------------------
sub gettime_unblock{

# 宣言
my($thistime) = @_;

my($thissec,$thismin,$thishour,$today,$mon,$year,$wday) = (localtime($thistime))[0..6];
my $thismonth = $mon+1;
my $thisyear = $year+1900;

# 日時のフォーマット
my($date) = sprintf("%04d/%02d/%02d", $thisyear,$thismonth,$today);

# リターン
return($date);

}





1;
