

use strict;
package Mebius::Auth;

#-----------------------------------------------------------
# 設定
#-----------------------------------------------------------
sub init_befriend{

return({
max_length_intro => 500,
wait_apply_hour => 24,
});

}

package main;

#-----------------------------------------------------------
# マイメビの処理
#-----------------------------------------------------------
sub auth_befriend{

my($init_befriend) = Mebius::Auth::init_befriend();
my($my_account) = Mebius::my_account();

# 宣言
our(%in);

	if($main::stop_mode =~ /SNS/){
		main::error("現在、SNSは更新停止中です。");
	}

# タイトル定義
our $title;
our $sub_title = "$main::friend_tag - $title";

# 連続申請の待ち時間 
my $wait_befriend = $init_befriend->{'wait_apply_hour'};
our $wait_befriend_sp = 6;
if($main::myaccount{'level2'} >= 1){ $wait_befriend = $wait_befriend_sp; }

# 汚染チェック
$main::in{'account'} =~ s/[^0-9a-z]//g;

our $head_link3 = qq(&gt; <a href="$main::in{'account'}/">$main::in{'account'}</a>);
our $head_link4 = "&gt; $main::friend_tag申\請";

	# 筆名未設定エラー
	if($my_account->{'birdflag'}){ main::error("このページを利用するには、あなたの筆名を設定してください。"); }

	#処理分岐
	if($main::in{'action'} && $main::in{'decide'} eq "ok"){ Mebius::Auth::AllowFriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "no"){ &auth_action_nofriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "delete"){ &auth_action_deletefriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "deny"){ Mebius::Auth::DenyFriend("",$wait_befriend); }
	elsif($main::in{'action'} && $main::in{'decide'} eq "intro"){ &auth_action_introfriend("",$wait_befriend); }
	elsif($main::in{'decide'} eq "edit"){ &auth_editfriend("",$wait_befriend); }
	elsif($main::in{'decide'} eq "ok"){ Mebius::Auth::AllowFriendView("",$wait_befriend); }
	elsif($main::in{'decide'} eq "no"){ &auth_nofriend("",$wait_befriend); }
	elsif($main::in{'decide'} eq "deny"){ &auth_denyfriend("",$wait_befriend); }
	else{ Mebius::Auth::BefriendForm("",$wait_befriend); }

}


package Mebius::Auth;

#-------------------------------------------------
# マイメビ申請用ページ
#-------------------------------------------------
sub BefriendForm{

# 局所化
my($type,$wait_befriend) = @_;
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();

# CSS定義
$main::css_text .= qq(
textarea.apply_comment{width:50%;height:100px;}
);

# プロフィールオープン、キーチェック
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error Lock-check-error",$main::in{'account'});

	# 筆名未設定エラー
	if($account{'birdflag'}){ main::error("このメンバーは筆名が未設定のため、申\請できません。"); }

# 登録済みかどうかをチェック
my(%friend1) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$account{'file'},$main::myaccount{'file'});
my(%friend2) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error Still-apply-check",$main::myaccount{'file'},$account{'file'});

	# 判定
	if($friend1{'staus'} eq "friend" && $friend2{'staus'} eq "friend"){ main::error("このメンバーには、既にマイメビです。"); }

	if($friend2{'status'} eq "apply" && !$my_account->{'admin_flag'}){ main::error("既に申\請中です。"); }

	# 申請の実行
	if($main::in{'action'}){ &BefriendApply("",$wait_befriend); }

	# スペシャル会員の紹介
	my($text1,$text2);
	if($main::myaccount{'level2'} < 1){ $text1 = qq(<a href="$main::myaccount{'file'}/spform">スペシャル会員登録</a>をすると、$main::friend_tagの上限を増やすことが出来ます。); }
	if($main::myaccount{'level2'} < 1){ $text2 = qq(<a href="$main::myaccount{'file'}/spform">スペシャル会員登録</a>をすると、待ち時間を$main::wait_befriend_sp時間に減らすことが出来ます。); }

# HTML
my $print = qq(
$main::footer_link
<h1$main::kstyle_h1>マイメビ申\請</h1>
<div class="line-height">
$account{'name_link'}さんに$main::friend_tag申\請します。</div><br$main::xclose>);

	# ストップモード
	if($main::stop_mode =~ /SNS/){ $print .= qq(<div>【現在、SNS全体で更新停止中です】</div><br>); }

	# ログインしていない場合
	elsif(!$main::myaccount{'file'}){
		$print .= qq(<div>申\請するには、アカウントに<a href="$basic_init->{'auth_url'}?backurl=$main::selfurl_enc">ログイン</a>してください。</div>);
	}

	# 自分のマイメビ最大数をチェック
	elsif($main::myaccount{'max_friend_flag'}){ $print .= qq($main::myaccount{'max_friend_flag'}); }

	# 相手のマイメビ最大数をチェック
	elsif($account{'max_friend_flag'}){ $print .= qq($account{'max_friend_flag'}); }

	# 連続申請チェック
	elsif($main::time < $main::myaccount{'last_apply_friend_time'} + $wait_befriend*60*60 && !$main::alocal_mode){
		$print .= qq(<div>連続申\請は出来ません。${wait_befriend}時間の間隔をあけてください。</div>);
	}

	# 普通に表示
	else{
		$print .= qq(
		<form action="$main::action" method="post"$main::sikibetu><div>
		<input type="hidden" name="mode" value="befriend">
		<input type="hidden" name="action" value="1">
		申\請コメント：<br$main::xclose><br$main::xclose>
		<textarea name="apply_comment" class="apply_comment"></textarea>
		<br$main::xclose><br$main::xclose><input type="hidden" name="account" value="$account{'file'}">
		<input type="submit" value="申\請する" class="isubmit">
		</div></form>
		);
	}

$print .= qq(
<br>
<div style="color:#f00;" class="line-height margin">
▲知り合い、興味のある人などに申\請してください。（無差別な申\請は控えてください）<br>
▲最大登録数は$main::max_myfriend人までです。$text1<br>
▲１回申\請をすると、次に申\請できるのは${wait_befriend}時間後です。$text2
</div><br>
$main::footer_link2

);

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}


#-------------------------------------------------
# マイメビ申請を実行する
#-------------------------------------------------
sub BefriendApply{

# 宣言
my($type,$wait_befriend) = @_;
my($time_handler,$befriend_handler,$i,@renew_line,%renew_option);
my($my_account) = Mebius::my_account();

# マイメビ申請の最大数（受け手側）の定義
my $maxline_befriend = 25;

# アクセス制限
main::axscheck("ACCOUNT Post-only Login-check");

# アカウントファイルを開く
my(%account) = Mebius::Auth::File("Option Get-hash File-check-error Key-check-error",$main::in{'account'});

	# マイメビ状態 / 禁止状態をチェック
	if(Mebius::alocal_judge() && $main::in{'apply_comment'} =~ /break/i){
		1;
	}
	else{
		Mebius::Auth::FriendStatus("Deny-check-error Yet-friend-check-error Me-check-error",$account{'file'},$my_account->{'file'});
		Mebius::Auth::FriendStatus("Deny-check-error Yet-friend-check-error Me-check-error",$my_account->{'file'},$account{'file'});
	}

# 申請済みかどうかをチェック
my($apply) = Mebius::Auth::ApplyFriendIndex(undef,$account{'file'},$main::myaccount{'file'});
if($apply->{'still_apply_flag'} && !Mebius::alocal_judge()){ main::error("このメンバーには、既に申\請済みです。"); }

# 筆名未設定エラー
if($account{'birdflag'}){ main::error("このメンバーは筆名が未設定のため、ページが利用できません。"); }

	# 連続申請チェック
	if(time < $my_account->{'last_apply_friend_time'} + $wait_befriend*60*60 && !Mebius::alocal_judge()){
		main::error("連続申\請は出来ません。${wait_befriend}時間の間隔をあけてください。");
	}

	# 申請コメントチェック
	if($main::in{'apply_comment'}){
		require "${main::int_dir}regist_allcheck.pl";
		main::all_check("Error-view",$main::in{'apply_comment'});
		if(length($main::in{'apply_comment'}/2) >= 1000){ main::error("申\請コメントが長すぎます。"); }
	}

# ロック開始
main::lock("friend");

# 相手のマイメビ申請ファイルを更新
my($new_apply) = Mebius::Auth::ApplyFriendIndex("New-apply Renew",$account{'file'},$my_account->{'file'},$main::myaccount{'name'},$main::in{'apply_comment'});


# 相手にメールを送信
my %mail;
$mail{'url'} = "$account{'file'}/aview-befriend";
$mail{'subject'} = qq($my_account->{'name'}さんから$main::friend_tag申\請が届きました。);
$mail{'comment'} = qq($main::in{'apply_comment'});
Mebius::Auth::SendEmail(" Type-etc",\%account,\%main::myaccount,\%mail);

# ロック解除
main::unlock("friend");

# 自分のファイル側で、相手のマイメビ状態を「申請中」に変更
Mebius::Auth::FriendStatus("Renew Apply-friend",$my_account->{'file'},$account{'file'});

# 自分の最終申請時間を更新
#$renew_option{'last_apply_friend_time'} = time;
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_option);

	# 自分の最終申請時間を更新
	{
		my(%renew_account);
		$renew_account{'last_apply_friend_time'} = time;
		Mebius::Auth::File("Renew Option",$my_account->{'file'},\%renew_account);
	}


# ページジャンプ
$main::jump_sec = $main::auth_jump;
$main::jump_url = "$account{'file'}/";


# HTML
my $print = qq($account{'name_link'}さんに$main::friend_tag申\請しました。（<a href="$main::jump_url">→戻る</a>）);

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

#-------------------------------------------------
# マイメビ許可のページ
#-------------------------------------------------
sub AllowFriendView{

my($flag,$print);
my($my_account) = Mebius::my_account();

# ログイン判定
Mebius::LoginedCheck("Error-view");

# アカウントファイルを開く
my(%account) = Mebius::Auth::File("Option File-check-error",$main::in{'account'});

# 登録済みかどうかをチェック
my(%friend1) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$account{'file'},$my_account->{'file'});
my(%friend2) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$my_account->{'file'},$account{'file'});

$main::head_link4 = "&gt; $main::friend_tag許可";


	# ストップモード
	if($main::stop_mode =~ /SNS/){
		$print = qq(
		$main::footer_link
		<h1>$main::friend_tag許可</h1>
		現在、SNS全体で更新停止中です。
		$main::footer_link2
		);

	}

	# 通常通り表示
	else{

		$print = qq(
		$main::footer_link
		<h1$main::kstyle_h1>$main::friend_tagを許可する</h1>
		<form action="$main::action" method="post"$main::sikibetu>
		<div>
		$account{'name_link'}さんを$main::friend_tag登録します。<br>
		よろしければ下のボタンを押してください。<br>
		<input type="hidden" name="mode" value="befriend">
		<input type="hidden" name="decide" value="ok">
		<input type="hidden" name="action" value="1">
		<input type="hidden" name="account" value="$main::in{'account'}"><br>
		<input type="submit" value="$main::in{'account'}さんを$main::friend_tag登録する">
		<br><br>
		</div></form>
		$main::footer_link2
		);

	}

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-------------------------------------------------
# マイメビの許可を実行する
#-------------------------------------------------
sub AllowFriend{

# 宣言
my($type) = @_;
my($file,$line,$line4,$line2);
my(%renew_friend_index1,%renew_friend_index2);
my($my_account) = Mebius::my_account();
my $operate = new Mebius::Operate;

# アクセス制限
main::axscheck("ACCOUNT Post-only Login-check");

# 相手のファイルを開く
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error",$main::in{'account'});

	# 自分のマイメビ最大数をチェック
	if($my_account->{'max_friend_flag'}){ main::error($my_account->{'max_friend_flag'}); }

	# 相手のマイメビ最大数をチェック
	if($account{'max_friend_flag'}){ main::error($account{'max_friend_flag'}); }

# 登録済みかどうかをチェック
my(%friend1) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$account{'file'},$my_account->{'file'});
my(%friend2) = Mebius::Auth::FriendStatus("Get-hash Deny-check-error Me-check-error",$my_account->{'file'},$account{'file'});

# ロック開始
main::lock("friend");

# 自分の承認待ちファイルを更新 ( 相手からの申請がない場合はエラーに ) ( A-1 )
	# ★エラーを表示するため、この処理を一番最初に置くこと
Mebius::Auth::ApplyFriendIndex("Allow-apply Renew",$my_account->{'file'},$account{'file'});

# 相手の承認待ちファイルを更新
Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$account{'file'},$my_account->{'file'});

# お互いのマイメビに、相手とマイメビになったことを伝える ( A- 1 )
Mebius::Auth::FriendIndex("Tell-new-friend",$my_account->{'file'},$account{'file'});
Mebius::Auth::FriendIndex("Tell-new-friend",$account{'file'},$my_account->{'file'});

# 自分のマイメビ一覧を更新 ( A- 2 )
$renew_friend_index1{'account'} = $account{'file'};
$renew_friend_index1{'handle'} = $account{'name'};
Mebius::Auth::FriendIndex("Renew New-friend",$my_account->{'file'},%renew_friend_index1);

# 相手のマイメビ一覧を更新 ( A- 2 )
$renew_friend_index2{'account'} = $my_account->{'file'};
$renew_friend_index2{'handle'} = $my_account->{'name'};
Mebius::Auth::FriendIndex("Renew New-friend",$account{'file'},%renew_friend_index2);

# 自分のマイメビ個別ファイルを作成
Mebius::Auth::FriendStatus("Renew Be-friend",$my_account->{'file'},$account{'file'});

# 相手のマイメビ個別ファイルを作成
Mebius::Auth::FriendStatus("Renew Be-friend",$account{'file'},$my_account->{'file'});

	# アカウントファイルを更新
	{
		my @my_account_friends = $operate->push_unique_near_array($my_account->{'friend_accounts'},$main::in{'account'});
		my @target_account_friends = $operate->push_unique_near_array($account{'friend_accounts'},$my_account->{'id'});

		Mebius::Auth::File("Renew",$my_account->{'id'},{ friend_accounts => "@my_account_friends" });
		Mebius::Auth::File("Renew",$main::in{'account'},{ friend_accounts => "@target_account_friends" });
	}

# ロック解除
main::unlock("friend");

# 記録
Mebius::AccessLog(undef,"SNS-be-friend","$my_account->{'file'} さんと $account{'file'} さんが 友だちになりました。");

# リダイレクト
Mebius::Redirect(undef,"$my_account->{'profile_url'}aview-befriend");

exit;


}

package main;

#-------------------------------------------------
# マイメビ拒否のページ
#-------------------------------------------------
sub auth_nofriend{

my($file,$flag);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
our($action);

# 汚染チェック
$file = $main::in{'account'};
$file =~ s/[^0-9a-z]//g;

# ログイン判定
Mebius::LoginedCheck("Error-view");

# アカウントファイルを開く
my(%account) = Mebius::Auth::File(undef,$file);
#&open($file,"nocheck");

# ディレクトリ定義
#my($account_directory) = Mebius::Auth::account_directory($file);
my($my_account_directory) = Mebius::Auth::account_directory($my_account->{'id'});
	if(!$my_account_directory){ die("Perl Die! Account directory setting is empty."); }

# 自分の承認待ちファイルを開く
open(MYBEFRIEND_IN,"<","${my_account_directory}$my_account->{'id'}_befriend.cgi");
while(<MYBEFRIEND_IN>){
my($account,$name) = split(/<>/,$_);
if($account eq $file){ $flag = 1 ; }
}
close(MYBEFRIEND_IN);

	# 承認待ちファイルに無い場合
	if(!$flag){ main::error("承認待ちでないメンバーは拒否できません。"); } 

# 登録済みかどうかをチェック
my($yetfriend) = &checkfriend($file);
	if($yetfriend){ main::error("このメンバーは、既に$main::friend_tag登録済みです。"); }

our $head_link4 = "&gt; $main::friend_tag拒否";


my $print = <<"EOM";
$main::footer_link
<h1>$main::friend_tag拒否</h1>
<form action="$action" method="post"$main::sikibetu>
<div>
<a href="$main::in{'account'}/">$account{'name'} - $file</a> さんを$main::friend_tag拒否します。<br>
よろしければ下のボタンを押してください。<br>
<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="no">
<input type="hidden" name="action" value="1">
<input type="hidden" name="account" value="$main::in{'account'}"><br>
<input type="submit" value="$main::in{'account'}さんを$main::friend_tag拒否する"><br><br>
＊ここでの登録は直接相手に通知されません。申\請そのものを止めるには<a href="$basic_init->{'auth_url'}?mode=befriend&amp;decide=deny&amp;account=$file">禁止設定</a>をおこなってください。
</div></form>
$main::footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-------------------------------------------------
# マイメビ拒否の実行
#-------------------------------------------------
sub auth_action_nofriend{

# 宣言
my($type) = @_;
my($my_account) = Mebius::my_account();

	# ＧＥＴ送信をブロック
	if($ENV{'REQUEST_METHOD'} ne "POST"){ main::error("ＧＥＴ送信は出来ません。"); }

# ログイン判定
Mebius::LoginedCheck("Error-view");

# 相手のアカウントファイルを開く
my(%account) = Mebius::Auth::File("Option File-check-error",$main::in{'account'});

# 自分の【承認待ちファイル】を更新
Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$main::myaccount{'file'},$account{'file'});

# 相手の【承認待ちファイル】を更新
Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$account{'file'},$main::myaccount{'file'});

# 自分の【マイメビ状態】を更新する
Mebius::Auth::FriendStatus("Delete-apply Renew",$main::myaccount{'file'},$account{'file'});

# 相手の【マイメビ状態】を更新する
Mebius::Auth::FriendStatus("Delete-apply Renew",$account{'file'},$my_account->{'file'});

# ページジャンプ
Mebius::Redirect(undef,"$my_account->{'profile_url'}aview-befriend");

exit;



}


#-------------------------------------------------
# マイメビ編集のページ
#-------------------------------------------------
sub auth_editfriend{

# 局所化
my($file,$flag,$link1,$admin_text);
my($edit_intro);
my($init_befriend) = Mebius::Auth::init_befriend();
my($my_account) = Mebius::my_account();
our($action);

# 紹介文の最大文字数(全角)
#our $max_intro = 500;

# ログイン判定
Mebius::LoginedCheck("Error-view");

# 独自CSS
our $css_text .= qq(
.stextarea{width:95%;height:10em;}
.max_intro{color:#f00;font-size:90%;}
);

# ファイルを定義（１）
$file = $main::in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ main::error("相手メンバーを指定してください。"); }

# ファイルを定義（２）
my $myfile = $main::in{'myaccount'};
$myfile =~ s/[^0-9a-z]//g;
if($myfile eq ""){ main::error("自分を指定してください。"); }

# ディレクトリ定義
#my($account_directory) = Mebius::Auth::account_directory($file);
my($my_account_directory) = Mebius::Auth::account_directory($main::in{'myaccount'});
	if(!$my_account_directory){ die("Perl Die! Account directory setting is empty."); }

# 自分でない場合
if(!$my_account->{'admin_flag'} && $myfile ne $my_account->{'id'}){ main::error("他のメンバーの$main::friend_tagは編集できません。"); }
if($my_account->{'admin_flag'} && $myfile ne $my_account->{'id'}){ $admin_text = qq(<strong class="red">※管理者として設定します。</strong><br>); }

open(MYFRIEND_IN,"<","${my_account_directory}${myfile}_friend.cgi");
while(<MYFRIEND_IN>){
my($key,$account,$name,$intro) = split(/<>/,$_);
if($file eq $account){ $edit_intro = $intro; $edit_intro =~ s/<br>/\n/g; $flag = 1; }
}
close(MYFRIEND_IN);

if(!$flag){ main::error("このメンバーは$main::friend_tag登録されていません。"); }

# プロフィールを開く
my(%account) = Mebius::Auth::File("File-check-error",$file);

# タイトル定義
our $head_link4 = "&gt; $main::friend_tag編集 : $account{'handle'} - $file";
$main::sub_title = qq($account{'handle'}の編集);


my $link1 = "$file/";

my $print = <<"EOM";
$main::footer_link
<h1>$main::friend_tag編集 - $account{'handle'}さん</h1>

<h2>紹介文の編集</h2>

$admin_text
※<a href="$link1">$account{'handle'} - $file</a>さんを紹介する文章を書いてください（優しい人、面白い人など）。<br>
<br>

<form action="$action" method="post"$main::sikibetu>
<div>
<textarea name="intro" class="stextarea">$edit_intro</textarea><br>
<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="intro">
<input type="hidden" name="account" value="$file">
<input type="hidden" name="myaccount" value="$myfile">
<input type="hidden" name="action" value="1">
<input type="submit" value="紹介文を編集する" class="isubmit">
　<strong class="max_intro">（全角$init_befriend->{'max_length_intro'}文字まで）</strong>
</div>
</form>

<h2>$main::friend_tag解除</h2>

<form action="$action" method="post"$main::sikibetu>
<div>

<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="delete">
<input type="hidden" name="account" value="$file">
<input type="hidden" name="action" value="1">
<a href="$link1">$account{'handle'} - $file</a> さんとの$main::friend_tag登録を解除します。よろしいですか？　
<br$main::xclose><br$main::xclose>


<input type="checkbox" name="check" value="1" id="friend_off"><label for="friend_off">はい、登録を解除します。</label> <br><br>

<input type="submit" value="$fileさんとの$main::friend_tag登録を解除する">

</div>
</form>
$main::footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}


#-------------------------------------------------
# 紹介文変更の実行
#-------------------------------------------------
sub auth_action_introfriend{

# 局所化
my($file,$line,$pline,$flag);
my($myfriend_handler,%renew);
my($init_befriend) = Mebius::Auth::init_befriend();
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
our($jump_url);

# アクセス制限
main::axscheck("Post-only Login-check");

	# アカウントロック中
	if($my_account->{'key'} eq "2" && $main::in{'intro'} !~ /^((\s|　|<br>)+)?$/){
		main::error("アカウントロック中は、紹介文を完全に削除する以外の変更は出来ません。");
	}

# ファイルを定義（１）
$file = $main::in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ main::error("相手メンバーを指定してください。"); }

# ファイルを定義（２）
my $myfile = $main::in{'myaccount'};

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$myfile)){ main::error("自分のアカウント名が間違っています。"); }
	if($myfile eq ""){ main::error("自分を指定してください。"); }

	# 自分でない場合
	if(!$my_account->{'admin_flag'} && $myfile ne $my_account->{'id'}){ main::error("他のメンバーの$main::friend_tagは編集できません。"); }

# エラー時のフック
our $fook_error = qq(入力内容： $main::in{'intro'});

# 各種エラー
require "${main::int_dir}regist_allcheck.pl";
($main::in{'intro'}) = &all_check(undef,$main::in{'intro'});
main::error_view("ERROR");

	# 紹介文が長すぎる場合
	if(length($main::in{'intro'}) > $init_befriend->{'max_length_intro'}*2){ main::error("紹介文が長すぎます。全角$init_befriend->{'max_length_intro'}文字までに収めてください。"); }

# 相手のアカウント名がない場合
if($file eq ""){ main::error("相手を指定してください。"); }

# 相手のプロフィールをオープン
my(%account) = Mebius::Auth::File(undef,$file);

# ロック開始
&lock("friend");

# 紹介文の変更 ( 自分のマイメビファイル )
$renew{'account'} = $file;
$renew{'intro'} = $main::in{'intro'};
Mebius::Auth::FriendIndex("Renew Change-introduction",$myfile,%renew);

my %renew_target;
$renew_target{'account'} = $myfile;
$renew_target{'be_intro'} = $main::in{'intro'};
Mebius::Auth::FriendIndex("Renew Change-be-introductioned",$account{'file'},%renew_target);

# 紹介文の変更 ( 相手のマイメビファイル )
my %renew_target;
$renew_target{'account'} = $myfile;
$renew_target{'be_intro'} = $main::in{'intro'};
Mebius::Auth::FriendIndex("Renew Change-be-introduction",$account{'file'},%renew_target);

	# 相手アカウントの 「最近の更新」ファイルを更新
	if(!$account{'myprof_flag'} || Mebius::alocal_judge()){
		Mebius::Auth::News("Renew Log-type-edit_introduction",$file,$myfile,$main::myaccount{'handle'},qq(<a href="$basic_init->{'auth_url'}$myfile/aview-friend#F_$file">紹介文の変更</a>));
	}

# SNS履歴を更新
Mebius::Auth::History("Renew",$my_account->{'id'},$file,qq(の<a href="$basic_init->{'auth_url'}$my_account->{'id'}/aview-friend#F_$file">紹介文</a>を変更しました。));

# ロック解除
&unlock("friend");

# ページジャンプ
Mebius::Redirect(undef,"$my_account->{'profile_url'}aview-friend");
;

# 処理終了
exit;


}

#-------------------------------------------------
# マイメビ削除 ( 登録解除 ) の実行
#-------------------------------------------------
sub auth_action_deletefriend{

# 宣言
my($file,$line,$line3);
my(%renew_friend_index1,%renew_friend_index2);
my($my_account) = Mebius::my_account();
my $operate = new Mebius::Operate;

	# チェックが入っていない場合
	if(!$main::in{'check'}){
		main::error("$main::friend_tag登録を解除するには、チェックを入れてください。");
	}

# ログイン判定
Mebius::LoginedCheck("Error-view");

# 相手のアカウントファイルを開く
my(%account) = Mebius::Auth::File("Option File-check-error",$main::in{'account'});

# ロック開始
main::lock("friend");

# お互いのマイメビの、相手とマイメビになったお知らせを削除する ( A- 1 )
Mebius::Auth::FriendIndex("Tell-cancel-friend",$my_account->{'file'},$account{'file'});
Mebius::Auth::FriendIndex("Tell-cancel-friend",$account{'file'},$my_account->{'file'});

# 自分のマイメビファイルを更新 ( A- 2 )
$renew_friend_index1{'account'} = $account{'file'};
Mebius::Auth::FriendIndex("Delete-friend Renew",$my_account->{'file'},%renew_friend_index1);

# 相手のマイメビファイルを更新 ( A- 2 )
$renew_friend_index2{'account'} = $my_account->{'file'};
Mebius::Auth::FriendIndex("Delete-friend Renew",$account{'file'},%renew_friend_index2);


# お互いのマイメビファイル×２を更新
Mebius::Auth::FriendStatus("Renew Delete-friend",$my_account->{'file'},$account{'file'});
Mebius::Auth::FriendStatus("Renew Delete-friend",$account{'file'},$my_account->{'file'});


	# アカウントファイルを更新
	{
		my @my_account_friends = $operate->delete_element_near_array($my_account->{'friend_accounts'},$main::in{'account'});
		my @target_account_friends = $operate->delete_element_near_array($account{'friend_accounts'},$my_account->{'id'});

		Mebius::Auth::File("Renew",$my_account->{'id'},{ friend_accounts => "@my_account_friends" });
		Mebius::Auth::File("Renew",$main::in{'account'},{ friend_accounts => "@target_account_friends" });
	}

# ロック解除
main::unlock("friend");

# マイプロフへジャンプ
main::auth_jumpme();

my $print = qq($account{'name_link'}さんとの$main::friend_tag登録を解除しました。<a href="$main::jump_url">マイアカウント</a>へ移動します。);

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}


#-------------------------------------------------
# 禁止設定のページ
#-------------------------------------------------
sub auth_denyfriend{

# 局所化
my($file,$flag,$stop1,$text1);
my($my_account) = Mebius::my_account();
my($basic_init) = Mebius::basic_init();
our($action);

# 自分のアカウントデータ
	if(!$my_account->{'login_flag'}){ main::error("このページはログインしていないと使えません。",401); }

# 相手のプロフィールを開く
my(%account) = Mebius::Auth::File("Option File-check-error Get-friend-status",$main::in{'account'},%$my_account);

# 自分に向けては実行できない
if($account{'friend_status_to'} eq "me"){ main::error("自分は禁止設定できません。"); }

# アカウント名
my $viewaccount = $account{'id'};
	if($account{'id'} eq "none"){ $viewaccount = "****"; }

	# 既に禁止済みの場合
	if($account{'friend_status_from'} eq "deny"){
		$text1 = qq(
		$account{'name_link'} さんは既に禁止設定中です。<br$main::xclose><br$main::xclose>
		$account{'name_link'} さんへの禁止設定を<strong style="color:#00f;">解除</strong> すると、<a href="$basic_init->{'auth_url'}$file">$account{'name'} - $viewaccount</a> さんはあなたの日記、伝言板等へ書き込めるようになります。
		<br><br>);
	}
	# まだ禁止していない場合
	else{
		$text1 = qq(
		<strong style="color:#f00;">禁止設定</strong> すると、$account{'name_link'} さんはあなたの日記、伝言板等へ書き込めなくなり、メッセージや猫の送信も禁止されます。（閲覧は可能\）。
		<br><br>);
	}

# タイトル定義
our $head_link4 = "&gt; 禁止設定 : $account{'name'} - $viewaccount";


# ＨＴＭＬ
my $print = <<"EOM";
$main::footer_link
<h1$main::kstyle_h1>禁止設定</h1>

<h2$main::kstyle_h2>編集</h2>
<form action="$action" method="post"$main::sikibetu>
<div class="line-height">
<input type="hidden" name="mode" value="befriend">
<input type="hidden" name="decide" value="deny">
<input type="hidden" name="account" value="$account{'file'}">
<input type="hidden" name="action" value="1">
$text1
よろしいですか？　

<input type="checkbox" name="check" value="1" id="deny_yes"> <label for="deny_yes">はい。</label><br><br>
<input type="submit" value="$viewaccountさんを禁止設定する">

</div>
</form>
<br>
$main::footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

package Mebius::Auth;

#-------------------------------------------------
# 禁止設定を実行
#-------------------------------------------------
sub DenyFriend{

# 宣言
my($line,$friend_handler,%renew,%renew_myaccount);
my($my_account) = Mebius::my_account();

# チェックが入っていない場合
if(!$main::in{'check'}){ main::error("実行するには、必要なチェックを入れてください。"); }

# アクセス制限
main::axscheck("Post-only Login-check");

# 相手のアカウントファイルを開く
my(%account) = Mebius::Auth::File("Option File-check-error Key-check-error",$main::in{'account'});

# ディレクトリ定義
my($my_account_directory) = Mebius::Auth::account_directory($main::myaccount{'file'});
	if(!$my_account_directory){ die("Perl Die! Account directory setting is empty."); }

# 汚染チェック
my $file = "${my_account_directory}friend/$account{'file'}_f.cgi";

	# 自分に向けては実行できない
	if($account{'file'} eq $my_account->{'id'}){ main::error("自分は禁止設定できません。"); }

# 禁止状況を調査
my($friend_status) = Mebius::Auth::FriendStatus("",$main::myaccount{'file'},$account{'file'});

	# マイメビの場合
	if($friend_status eq "friend"){ main::error("設定するには、一度$main::friend_tag登録を解除してください。"); }

	# 禁止設定を解除する場合
	if($friend_status eq "deny"){

		# 自分のマイメビファイルを削除
		unlink($file);

		# オプションファイルの更新値
		#$renew{'plus->denied_count'} = -1;
		#$renew_myaccount{'plus->deny_count'} = -1;
		$renew{'-'}{'denied_count'} = 1;
		$renew_myaccount{'-'}{'deny_count'} = 1;

	}

	# 禁止設定をする場合
	else{

		# 自分のマイメビ状態を更新 ( 拒否状態に )
		Mebius::Auth::FriendStatus("Renew Deny-friend",$main::myaccount{'file'},$account{'file'});

		# 相手のマイメビ状態を更新 ( 申請中の場合は取り消し )
		Mebius::Auth::FriendStatus("Renew Delete-apply",$account{'file'},$main::myaccount{'file'});

		# 自分の承認待ちファイルを更新 ( 申請を削除 )
		Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$main::myaccount{'file'},$account{'file'});

		# 相手の承認待ちファイルを更新 ( 申請を削除 )
		Mebius::Auth::ApplyFriendIndex("Delete-apply Renew",$account{'file'},$main::myaccount{'file'});

		# オプションファイルの更新値
		#$renew{'plus->denied_count'} = +1;
		#$renew_myaccount{'plus->deny_count'} = +1;
		$renew{'+'}{'denied_count'} = 1;
		$renew_myaccount{'+'}{'deny_count'} = 1;

	}


# 相手のアカウントを更新
#Mebius::Auth::Optionfile("Renew",$account{'file'},%renew);
Mebius::Auth::File("Renew Option",$account{'file'},\%renew);

# 自分のアカウントを更新
#Mebius::Auth::Optionfile("Renew",$main::myaccount{'file'},%renew_myaccount);
Mebius::Auth::File("Renew Option",$main::myaccount{'file'},\%renew_myaccount);

# ジャンプ
$main::jump_sec = $main::auth_jump;
$main::jump_url = qq($account{'file'}/);


# ＨＴＭＬ
my $print = qq(禁止設定を変更しました。<a href="$main::jump_url">プロフィールページ</a>へ移動します。);

Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

#-----------------------------------------------------------
# 相手からの紹介文ファイル ( 未実装 )
#-----------------------------------------------------------
sub BeIntroductionedFile{

# 宣言
my($type,$account,$from_account) = @_;
my(undef,undef,undef,$new_from_handle,$new_introduction_comment) = @_ if($type =~ /New-introduction/);
my($i,@renew_line,%data,$file_handler);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $directory1 = $account_directory;
my $file1 = "${directory1}${account}_beintroductioned.log";

	# ファイルを開く
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("ファイルが存在しません。");
	}
	else{
		open($file_handler,"<$file1");
	}


	# ファイルロック
	if($type =~ /Renew/){ flock($file_handler,1); }

# トップデータを分解
chomp(my $top1 = <$file_handler>);
($data{'key'}) = split(/<>/,$top1);

	# ファイルを展開
	while(<$file_handler>){

		# ラウンドカウンタ
		$i++;
		
		# この行を分解
		chomp;
		my($key2,$from_account2,$from_handle2,$introduction_comment2) = split(/<>/);

			# 重複禁止
			if($type =~ /Renew/){
					if($from_account2 eq $from_account){ next; }
			}

			# 行を追加
			if($type =~ /Renew/){
				push(@renew_line,"$key2<>$from_account2<>$from_handle2<>$introduction_comment2<>\n");
			}

	}

close($file_handler);


	# 新規紹介文を追加
	if($type =~ /New-introduction/){
		unshift(@renew_line,"<>$from_account<>$new_from_handle<>$new_introduction_comment<>\n");
	}

	# ファイル更新
	if($type =~ /Renew/){

		# ディレクトリ作成
		Mebius::Mkdir(undef,$directory1);

		# トップデータを追加
		unshift(@renew_line,"$data{'key'}<>\n");

		# ファイル更新
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}

package main;

#-------------------------------------------------
# マイプロフへのジャンプ
#-------------------------------------------------

sub auth_jumpme{

my($url);
my($my_account) = Mebius::my_account();
our $jump_sec = our $auth_jump;

$url = "$my_account->{'id'}/$_[0]";
our $jump_url = "$url";

}

1;

