
use Mebius::Auth;
use Mebius::SNS::Feed;
package main;
use Mebius::Export;

# -------------------------------------------
# 配布元サイトの設定なので、いじらない方が良いです。
# -------------------------------------------
sub init_start_sns{

my($init) = Mebius::SNS->init();

$auth_jump = 0;
$auth_domain = "mb2.jp";

$home = "http://mb2.jp/";
$adir = "../";

	if(Mebius::alocal_judge()){ $script = "/_auth/"; }
	else{ $script = "/"; }

$max_putid = 10;
$max_msg_comment = 1000;

# リンク設定の名前（友達、マイリンクなど）
$friend_tag = "マイメビ";

# タイトル設定
$title = shift_jis_return($init->{'title'});
$sub_title = qq(メビリンＳＮＳ);

# ＳＮＳルールのＵＲＬ
$sns_rule = "${guide_url}%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3%A4%CE%A5%EB%A1%BC%A5%EB";

# ＢＢＳでスレッドを作れる最大数
$max_bbs = 10;
$sp_max_bbs = 100;

# ＢＢＳで１スレッドあたり、レス最大数
$maxres_bbs = 1000;

# 日記１個あたり、レス最大数
$maxres_diary = 1000;

# 元配布サイトなし
$original_maker = qq(<a href="http://aurasoul.mb2.jp/wiki/guid/%A3%D3%A3%CE%A3%D3%A4%C3%A4%DD%A4%A4%A4%E2%A4%CE%A1%A7%C7%DB%C9%DB">Script-メビウスリング</a>);
utf8($original_maker);

#$main::stop_mode = "Make-new-account";
$main::sns{'flag'} = 1;

# CSS
push(@main::css_files,"auth");

	# メインサーバーの場合
	if($main::auth_url =~ m!^http://$main::server_domain/!){
		$main::sns{'main_server_flag'} = 1;
	}

our($footer_link,$footer_link2) = footer_link();

return();

}

use strict;

#-------------------------------------------------
# スタート - スクリプト
#-------------------------------------------------
sub start_sns{

my($init_directory) = Mebius::BaseInitDirectory();
my($init_basic) = Mebius::basic_init();
my($server_domain) = Mebius::server_domain();
my($my_account) = Mebius::my_account();
my($my_use_device) = Mebius::my_use_device();
my($param) = Mebius::query_single_param();
my $feed = new Mebius::SNS::Feed;
my $query = new Mebius::Query;
our($mode,$submode1,$submode2,%in,$head_link1_25,$head_link2,$title,$script);

# 警告文
our $ipalert = qq(<strong class="ipalert">★書き込みをすると、あなたの接続元（ <a href="$init_basic->{'guide_url'}%C0%DC%C2%B3%A5%C7%A1%BC%A5%BF" class="blank" target="_blank">$ENV{'REMOTE_ADDR'}</a> ）が保存されます。
必ず<a href="$init_basic->{'guide_url'}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7" class="blank" target="_blank">サイト全体のルール</a>、<a href="$init_basic->{'guide_url'}%A5%E1%A5%D3%A5%EA%A5%F3%A3%D3%A3%CE%A3%D3" class="blank" target="_blank">SNSのルール</a>をご覧ください。</strong>);

# リンクタグ定義
our $html = ".html";

# 投稿先決定
#if($aurl_mode){ $action = $script = $basic_init->{'auth_url'} = "auth.cgi"; $adir = ""; }
our $action = qq($init_basic->{'auth_url'});

	# 携帯版用の処理
	if($my_use_device->{'mobile_flag'}){ main::kget_items(); }

	# ヘッダリンク
	if($param->{'mode'} eq "feed" || $param->{'mode'} eq ""){
		$head_link2 = qq( SNS)
	} else {
			if($my_account->{'file'}){ $head_link2 = qq( <a href="$init_basic->{'auth_url'}$my_account->{'file'}/feed">SNS</a> ); }
			else{ $head_link2 = qq( <a href="$init_basic->{'auth_url'}">SNS</a> ); }
	}

	# ドメインチェック
	if($init_basic->{'auth_url'} !~ m!^http://$server_domain/! && !Mebius::alocal_judge()){

			if($mode ne "logout" && $mode ne "editprof" && $mode ne "aview-history" && $mode ne "aview-remain" && $submode2 ne "login" && $mode ne "aview-login" && $mode ne "login" && $mode ne "baseedit" && $mode ne "makeid" && $mode ne "idmaked" && $mode ne "" || ($mode eq "" && $in{'account'} ne "") ){
				&error("このドメイン $main::server_domain では、このページは使えません。");
			}
	}


	# モード振り分け
	#if($submode1 eq "cdx"){ require "${init_directory}auth_cdx.pl"; auth_cdx(); } 
	if($mode eq "feed"){ Mebius::Auth::feed_view(); }
	elsif($mode eq "viewfriend"){ Mebius::Redirect("","$init_basic->{'auth_url'}$in{'account'}/aview-friend",301); } 
	elsif($mode eq "editprof"){ require "${init_directory}auth_edit.pl"; auth_editprof(); } 
	elsif($mode eq "idmaked"){ require "${init_directory}auth_idmaked.pl"; auth_idmaked(); } 
	elsif($mode eq "login"){ Mebius::Login->login(); }
	#elsif($mode eq "login_check"){ require "${init_directory}auth_login_old.pl"; auth_login_old(); }
	#elsif($mode eq "login_check_view"){ require "${init_directory}auth_login_old.pl"; auth_login_old_view(); }
	elsif($mode eq "comdel"){ require "${init_directory}auth_comdel.pl"; auth_comdel(); } 
	elsif($mode eq "logout" && $query->get_method()){ my $login = new Mebius::Login; $login->logout_form_view(); }
	elsif($mode eq "logout"){ my $login = new Mebius::Login; $login->logout(); }
	elsif($mode eq "kind_of_email_provider"){ Mebius::SNS::Account->kind_of_email_provider_view(); } 
	elsif($mode eq "comment"){ require "${init_directory}auth_comment.pl"; auth_comment(); } 
	elsif($submode1 eq "d"){ require "${init_directory}auth_diary.pl"; auth_diary(); } 
	elsif($mode eq "fdiary"){ require "${init_directory}auth_fdiary.pl"; auth_fdiary(); } 
	elsif($submode1 eq "diax"){ require "${init_directory}auth_diax.pl"; auth_diax(); } 
	elsif($mode eq "friend_feed"){ $feed->my_friend_news_view(); } 
	elsif($submode1 eq "crap"){ require "${init_directory}auth_crap.pl"; Mebius::Auth::CrapStart($param->{'account'},$param->{'diary_number'}); } 
	elsif($submode1 eq "crapview"){
		require "${init_directory}auth_crap.pl";
		Mebius::Auth::CrapIndexViewStart(undef,$main::submode2,$main::submode3,$main::submode4);
	}
	elsif($submode1 eq "kr"){ require "${init_directory}auth_kr.pl"; auth_kr(); } 
	elsif($submode1 eq "news"){ require "${init_directory}auth_news.pl"; &news_auth(); } 
	#elsif($mode eq "keditdiary"){ require "${init_directory}auth_keditdiary.pl"; auth_keditdiary(); } 
	elsif($mode eq "resdiary"){ require "${init_directory}auth_resdiary.pl"; auth_resdiary(); } 	
	elsif($mode eq "skeditdiary"){ require "${init_directory}auth_skeditdiary.pl"; auth_skeditdiary(); } 
	elsif($submode1 eq "b"){ require "${init_directory}auth_bbs.pl"; auth_bbs(); } 
	elsif($mode eq "keditbbs"){ require "${init_directory}auth_keditbbs.pl"; auth_keditbbs(); } 
	elsif($mode eq "skeditbbs"){ require "${init_directory}auth_skeditbbs.pl"; auth_skeditbbs(); } 
	elsif($mode eq "befriend"){ require "${init_directory}auth_befriend.pl"; auth_befriend(); } 
	elsif($mode eq "makeid"){ Mebius::SNS::NewAccount->submit(); }
	elsif($mode eq "new_account"){ Mebius::SNS::NewAccount->mode_junction(); }
	elsif($mode eq "baseedit"){ require "${init_directory}auth_edit.pl"; auth_baseedit(); } 
	elsif($submode1 eq "viewcomment"){ require "${init_directory}auth_comment.pl"; auth_view_comment(); } 
	elsif($mode eq "vrireki"){ require "${init_directory}auth_vrireki.pl"; auth_vrireki(); } 
	elsif($submode1 eq "vote"){ require "${init_directory}auth_vote.pl"; Mebius::Auth::Vote::Mode("",$submode2,%in); } 
	elsif($submode1 eq "spform"){ require "${init_directory}auth_spform.pl"; auth_spform(); } 
	elsif($submode1 eq "tag"){ require "${init_directory}auth_tag.pl"; auth_tag(); } 
	elsif($mode eq "message"){ require "${init_directory}auth_message.pl"; Mebius::Auth::MessageFormStart(); } 
	elsif($mode eq "friend-diary"){ require Mebius::SNS::Friend; Mebius::Auth::FriendDiaryIndexView(); }
	elsif($mode eq "aview-remain" || $mode eq "remain"){ require "${init_directory}auth_remain_pass.pl"; auth_remain_pass(); }
	elsif($mode eq "kindex" || $mode eq "km0"){ Mebius::Redirect("",$init_basic->{'auth_url'},"301"); } 
	elsif($submode1 eq "edit"){ require "${init_directory}auth_myform.pl"; auth_myform_page(); } 
	elsif($mode eq "sns_profile_iframe"){ require Mebius::BBS::Account; Mebius::BBS::sns_profile_for_iframe(); }
	else{
			if($in{'account'} && $mode eq ""){ require "${init_directory}auth_prof.pl"; auth_prof(); } 
			elsif($mode eq ""){ require "${init_directory}auth_makeid.pl"; Mebius::Auth::Index(); } 
			elsif($submode1 eq "aview" || $submode1 eq "iview"){ require "${init_directory}auth_aview.pl"; auth_aview(); } 
			else{ &error("ページが存在しません。[bauth]"); }
	}

}


#-------------------------------------------------
# 自動リンク
#-------------------------------------------------
sub auth_auto_link{

my($msg,$mode) = @_;
our($submode1,$submode2);

($msg) = Mebius::auto_link($msg);

	if($mode eq "RESNUM"){
		$msg =~ s/No\.([0-9]+)/<a href=\"$submode1-$submode2-$1\">&gt;&gt;$1<\/a>/g;
	}

return($msg);
}


#-----------------------------------------------------------
# SNS用の共通 HTML書き出し
#-----------------------------------------------------------
sub auth_html_print{

# 宣言
my($print_line,$tell_title,$account) = @_;
my($print);
my($basic_init) = Mebius::basic_init();
our($footer_link,$footer_link2,$sub_title,$head_link3,$head_link4,$title,$kfontsize_h1,$kfontsize_small);

# タイトル定義
$sub_title = "$tell_title | $title";

	# アカウント指定がある場合
	if($account->{'file'}){
		$head_link3 = qq(&gt; <a href="$basic_init->{'auth_url'}$account->{'file'}/">$account->{'file'}</a>);
		$sub_title = "$tell_title | $account->{'name'} - $account->{'file'} | $title";

	}

$head_link4 = qq(&gt; $tell_title);

$print .= qq($footer_link);

$print .= qq(<h1$kfontsize_h1>$tell_title ： $account->{'name'} - $account->{'file'}</h1>);
$print .= qq(<div$main::kfontsize_xsmall>);
$print .= qq(<a href="$basic_init->{'auth_url'}$account->{'file'}/">プロフィールへ</a>);
	#if($type =~ /Myfriend-link/ && $main::pmfile){ $print .= qq( <a href="$main::auth_url$main::pmfile/aview-friend">あなたのマイメビ</a>); } 
$print .= qq(</div>);

$print .= $print_line;

$print .= qq($footer_link2);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-------------------------------------------------
# 赤帯リンクを定義 - ヘッダ、フッター
#-------------------------------------------------

sub footer_link{

my $top_links = shift_jis_return(Mebius::SNS->my_navigation_links({ Top => 1 }));
my $bottom_links = shift_jis_return(Mebius::SNS->my_navigation_links({ Bottom => 1 }));

$top_links,$bottom_links;

}


no strict;

#-------------------------------------------------
# アローカルモードＵＲＬ処理
#-------------------------------------------------

sub aurl{

my $url = $_[0];

$url =~ s/([a-z0-9]+)\/([a-z0-9\-]+|)/$script?mode=$2&amp;account=$1/g;
$url =~ s/$script\?mode=&amp;account=/$script\?account=/g;

#$url =~ s/([a-z0-9]+)-([a-z0-9]+)/$script?mode=$1-$2/g;

return($url);

}

#-------------------------------------------------
# 取り込み処理
#-------------------------------------------------
sub checkfriend{ require "${int_dir}auth_checkfriend.pl"; &do_auth_checkfriend(@_); }
#sub checkbefriend{ require "${int_dir}auth_checkbefriend.pl"; &do_auth_checkbefriend(@_); }
sub open{ require "${int_dir}auth_open.pl"; &do_auth_open(@_); }
sub sns_sendmail{ require "${int_dir}auth_sendmail.pl"; &sns_sendmail2(@_); }

1;

