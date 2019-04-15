
package main;

#-------------------------------------------------
# 月別インデックス表示
#-------------------------------------------------
sub auth_alldiary{

# 局所化
my($file,$link,$line);

# モジュール読み込み
my($init_directory) = Mebius::BaseInitDirectory();
require "${init_directory}auth_diax.pl";

# 最大取得月数
$max_month = 12;

# 汚染チェック１
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# プロフィールを開く
&open($file);

# ユーザー色指定
if($ppcolor1){ $css_text .= qq(h2{background-color:#$ppcolor1;border-color:#$ppcolor1;}); }

# マイメビ状態の取得
&checkfriend($file);

# 日記表示の制限
if($pplevel >= 1 || !$mebi_mode){
if($pposdiary eq "2"){
if(!$yetfriend && !$myprof_flag && !$myadmin_flag){ &error("インデックスが存在しません。"); }
$text1 = qq(<em class="green">●$friend_tagだけに日記公開中です。</em><br><br>);
$onlyflag = 1;
}
elsif($pposdiary eq "0"){
if(!$myprof_flag && !$myadmin_flag){ &error("インデックスが存在しません。"); }
$text1 = qq(<em class="red">●自分だけに日記公開中です。</em><br><br>);
$onlyflag = 1;
}
}

# 全インデックスを取得
my($line) .= Mebius::SNS::Diary::index_file_per_account({ file_type => "now" } , $file);

# アカウント名
my $viewaccount = $ppfile;
if($ppname eq "none"){ $viewaccount = "****"; }

# タイトル定義
$sub_title = qq(全日記 : $ppname - $viewaccount);
$head_link3 = qq( &gt; <a href="./">$ppname</a> );
$head_link4 = qq( &gt; 全日記 );

# ＣＳＳ定義
$css_text .= qq(
.lock{color:#070;}
h1{color:#080;}
);



# インデックスを取得
my($line) = shift_jis(Mebius::SNS::Diary::all_diary_index_file_per_account($file,$max_month));
my($all_month_index) = auth_all_diary_month_index(undef,$file);

$link = qq($adir$file/);

# ＨＴＭＬ
my $print = <<"EOM";
$footer_link
<h1>全日記（$max_monthヶ月分） : $ppname - $viewaccount</h1>
$text1
<a href="$link">$ppname - $viewaccount のプロフィールに戻る</a>
<h2 id="INDEX">全日記</h2>
$line
<h2>月別一覧</h2>
$all_month_index
<br><br>
$footer_link2
EOM

# ヘッダ
Mebius::Template::gzip_and_print_all({},$print);

# 処理終了
exit;

}

#──────────────────────────────
# 日記インデックス
#──────────────────────────────

#sub auth_alldiary_getmonth{

## ファイル定義
##my($file,$year,$month) = @_;
#my($diary_index);

## ディレクトリ定義
#my($account_directory) = Mebius::Auth::account_directory($file);
#	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

## 現行インデックスを読み込み
#open(INDEX_IN,"<","${account_directory}diary/${file}_diary_${year}_${month}.cgi") || &error("インデックスが存在しません。");
#while(<INDEX_IN>){
#my($key,$num,$sub,$res,$dates,$newtime) = split(/<>/,$_);
#my($year,$month,$day,$hour,$min) = split(/,/,$dates);
#my($link,$mark,$line);

#$link = qq($adir${file}/d-$num);
#if($aurl_mode){ ($link) = &aurl($link); }

#if($key eq "0"){ $mark .= qq(<span class="lock"> - ロック中</span> ); }

## 普通に表示する
#if($key eq "0" || $key eq "1"){
#if($time < $newtime + 3*24*60*60){ $mark .= qq(<span class="red"> - new!</span> ); }
#$diary_index .= qq(<li><a href="$link">$sub</a> ($res) - $month月$day日$mark);

#if($myadmin_flag >= 1){
#$diary_index .= qq( - <a href="${auth_url}?mode=keditdiary&amp;account=$in{'account'}&amp;num=$num&amp;decide=delete">削除</a>);
#$diary_index .= qq( - <a href="${auth_url}?mode=keditdiary&amp;account=$in{'account'}&amp;num=$num&amp;decide=delete&amp;penalty=1">罰削除</a>);
#}

#$diary_index .= qq(</li>);

#}

## 削除済みの場合
#else{
#my($text);
#if($key eq "2"){ $text = qq( アカウント主により削除); }
#elsif($key eq "4"){ $text = qq( 管理者により削除); }
#if($myadmin_flag >= 1){ $text .= qq( <a href="$link" class="red">$sub</a>); }
#$diary_index .= qq(<li>$text - $month月$day日</li>);
#}


#}
#close(INDEX_IN);

#return($diary_index);

#}


1;
