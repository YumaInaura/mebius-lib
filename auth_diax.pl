
use Mebius::SNS;
package main;
use Mebius::Export;

#-------------------------------------------------
# 月別インデックス表示
#-------------------------------------------------
sub auth_diax{

my($basic_init) = Mebius::basic_init();

# 検索モードへ移行
if($submode2 eq "all"){ require "${int_dir}auth_alldiary.pl"; &auth_alldiary(); }

# 局所化
my($file,$link);

# 汚染チェック１
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# 汚染チェック２
$openyear = $submode2;
$openyear =~ s/\D//g;

# 汚染チェック３
$openmonth = $submode3;
$openmonth =~ s/\D//g;

# プロフィールを開く
&open($file);

# ユーザー色指定
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# マイメビ状態の取得
&checkfriend($file);

	# 日記表示の制限
	if($pplevel >= 1){
		if($pposdiary eq "2"){
				if(!$yetfriend && !$myprof_flag && !Mebius::SNS::admin_judge()){ &error("インデックスが存在しません。"); }
					$text1 = qq(<em class="green">●$friend_tagだけに日記公開中です。</em><br><br>);
					$onlyflag = 1;
				}
				elsif($pposdiary eq "0"){
						if(!$myprof_flag && !Mebius::SNS::admin_judge()){ &error("インデックスが存在しません。"); }
					$text1 = qq(<em class="red">●自分だけに日記公開中です。</em><br><br>);
					$onlyflag = 1;
				}
	}

# インデックスを取得
my($diary_index) = shift_jis(Mebius::SNS::Diary::view_index_per_account("month",$file,$openyear,$openmonth));
$diary_index = auth_diary_menu_round_form($file,$diary_index);

my($allindex) = auth_all_diary_month_index({ selected_year => $openyear , selected_month => $openmonth },$file);

# 筆名
my $viewaccount = $ppfile;
if($ppname eq "none"){ $viewaccount = "****"; }

# タイトル定義
$sub_title = qq($openyear年$openmonth月の日記 : $ppname - $viewaccount);

# ＣＳＳ定義
$css_text .= qq(
.lock{color:#070;}
h1{color:#080;}
);


$link = qq($adir$file/);

# ＨＴＭＬ
my $print = <<"EOM";
$footer_link
<h1>$openyear年$openmonth月の日記 : $ppname - $viewaccount</h1>
$text1<a href="$link">$ppname - $viewaccount のプロフィールに戻る</a>
<h2 id="INDEX">日記一覧</h2>
$diary_index
<h2>月別一覧</h2>
$allindex
<br><br>
$footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

use strict;

#-----------------------------------------------------------
# 日記操作用のフォームで囲む
#-----------------------------------------------------------
sub auth_diary_menu_round_form{

my($account,$diary_index) = @_;
my($basic_init) = Mebius::basic_init();

	if($diary_index && (Mebius::SNS::admin_judge() || Mebius::SNS::Diary::allow_user_revive_judge($account))){

		$diary_index = qq(
		<form method="post" method=").e($basic_init->{'auth_relative_url'}).qq("><input type="hidden" name="mode" value="skeditdiary">$diary_index<div class="margin"><input type="submit" value="操作を実行する"></div></form>
		);
	} else {
		0;
	}

$diary_index;

}

#-----------------------------------------------------------
# 全日記の月別インデックス
#-----------------------------------------------------------
sub auth_all_diary_month_index{

my($use,$account) = @_;
my($allindex);
my($init_directory) = Mebius::BaseInitDirectory();
my($basic_init) = Mebius::basic_init();
my(@year);

	# アカウント名判定
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# 全インデックスを読み込み
my $this_year;
open(ALL_INDEX_IN,"<","${account_directory}diary/${account}_diary_allindex.cgi");
	while(<ALL_INDEX_IN>){
		my($key,$year,$month) = split(/<>/,$_);
			if($this_year ne $year){
				$this_year = $year;
				$allindex .= "<b>${this_year}年</b> ";
			}
			if($key){ $allindex .= qq(<a href="$basic_init->{'auth_url'}$account/diax-$year-$month">$month月</a> ); }
	}
close(ALL_INDEX_IN);

return($allindex);

}


1;
