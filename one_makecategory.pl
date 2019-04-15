
my($line,$i);

# カテゴリ最大登録数
my $maxcategory = 100;

# カテゴリ名の最大文字数
my $maxlength = 20;

# 各種エラー
#if(!$postflag){ &error("GET送信は出来ません。"); }
if(!$idcheck){ &error("書き込むには、<a href=\"$auth_url\">メビリンＳＮＳ</a>にログイン（または新規登録）してください。"); }

# 投稿制限
($host) = &axscheck("ACCOUNT");

# 各種チェック
require "${int_dir}regist_allcheck.pl";
&length_check($in{'category'},"カテゴリ名",$maxlength,1);
&url_check("",$in{'category'});
&error_view;

# ロック開始
&lock("${pmfile}ONE") if $lockkey;

# 基本ファイルを開く
&base_open($pmfile);

# 登録開始してない場合
if($key_base ne "1"){ &error("登録開始してください。"); }

my $plus = $num_base +1;

# キー設定
my($newkey);
if($in{'type'} eq "secret"){ $newkey = 4; } else { $newkey = 1; }

# 追加する行
$line .= qq($in{'category'}<>$plus<>$newkey<>\n);

# カテゴリ記録ファイルを開く
open(CATE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
while(<CATE_IN>){
my($category) = split(/<>/,$_);
if($category eq $in{'category'}){ &error("このカテゴリは登録済みです。"); }
$i++;
if($i >= $maxcategory){ &error("カテゴリの最大登録数は$maxcategory個です。新規登録するには、今あるカテゴリのどれかを削除してください。"); } 
$line .= $_;
}
close(CATE_IN);

# カテゴリ記録ファイルに書き込む
open(CATE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
print CATE_OUT $line;
close(CATE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");

# コメントファイルに書き込む
my $line_ocm = qq($newkey<>$in{'category'}<>$date<>$xip<>$cnumber<>$host<><>\n);
open(OCM_OUT,">${int_dir}_one/_idone/${pmfile}/${plus}_ocm.cgi");
print OCM_OUT $line_ocm;
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${plus}_ocm.cgi");

# 基本ファイルを更新
$line_base = qq($key_base<>$plus<>$name_base<>$trip_base<>$id_base<>$account_base<>$itrip_base<>$plus<>$viewtime_base<>$mainnews_base<>$news_base<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
print BASE_OUT $line_base;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");

# ロック解除
&unlock("${pmfile}ONE") if $lockkey;

# リダイレクト
if($alocal_mode){ print qq(location:$script?mode=view-$pmfile-$plus-1\n\n); }
print qq(location:view-$pmfile-$plus-1.html\n\n);

1;
