

# 最小文字数
my $minmsg = 1;
# 最大文字数
my $maxmsg = 500;
# 全カテファイルの最大行数
my $maxall = 100;
# １コメントファイルあたりの最大行数
my $maxline = 1000;
# 新着コメントファイルの最大行数
my $maxnew = 250;

# 局所化
my($line,$flag,$line_all,$i_all,$file,$put_category,$line_new,$put_date,$key_all,$newcolor);

# 各種エラー
if(!$postflag){ &error("GET送信は出来ません。"); }
if(!$idcheck){ &error("書き込むには、<a href=\"$auth_url\">メビリンＳＮＳ</a>にログイン（または新規登録）してください。"); }

# 投稿制限
($host) = &axscheck();

# 各種エラーチェック
require "${int_dir}regist_allcheck.pl";
&length_check($in{'comment'},"内容",$maxmsg,1);
&url_check("",$in{'comment'});
($in{'comment'}) = &base_change($in{'comment'});
&error_view;

# 色のチェック
if($in{'color'}){
$newcolor = $in{'color'};
$newcolor =~ s/\W//g;
if(length($newcolor) > 3){ &error("色指定が変です。"); }
}

# ロック開始
&lock("${pmfile}ONE") if $lockkey;

# 基本ファイルを開く
&base_open($pmfile);

# ファイルがない場合
if($key_base ne "1"){ &error("ファイルが存在しません。"); }

# カテゴリ記録ファイルを開く
open(CATE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
while(<CATE_IN>){
my($category,$num) = split(/<>/,$_);
if($category eq $in{'category'}){ $put_category = $category; $file = $num; }
}
close(CATE_IN);

# カテゴリが一致しない場合
if($put_category eq ""){ &error("このカテゴリは存在しません。"); }

# ファイル定義
$file =~ s/\D//g;
if(!$file){ &error("データが変です。"); }

# 公式カテゴリを展開
foreach(@base_category){
my($category,$guide) = split(/=/,$_);
if($category eq $in{'category'}){ $pure_flag = 1; }
}

# コメントファイルを開く
my($i);
open(COMMENT_IN,"${int_dir}_one/_idone/${pmfile}/${file}_ocm.cgi");
my $top_comment = <COMMENT_IN>;
chomp $top_comment;
my($key_ocm,$sub_ocm,$date_ocm,$xip_ocm,$cnumber_ocm,$host_ocm,$guide_ocm) = split(/<>/,$top_comment);
while(<COMMENT_IN>){
my($key,$comment,$date) = split(/<>/,$_);
if($key eq ""){ next; }
$i++;
if($i > $maxline){ &error("最大登録数 -$maxline件- を越えています。"); }
if($key eq "1" && $comment eq $in{'comment'}){ &error("二重登録です。"); }
$line .= $_;
}
close(COMMENT_IN);

# シークレットモードの場合
my($secret_flag);
if($key_ocm eq "4"){ $secret_flag = 1 ; }
if($in{'secret'}){ $secret_flag = 1; }

# コメントの新しいキー
my($newkey_ocm);
if($secret_flag){ $newkey_ocm = 4; }
else{ $newkey_ocm = 1; }

# 追加する行（コメントファイル）
$i++;
my $top_line .= qq($key_ocm<>$put_category<>$date<>$xip<>$cnumber<>$host<>$guide_ocm<>\n);
$top_line .= qq($newkey_ocm<>$in{'comment'}<>$date<>$i<>$newcolor<>\n);

# コメントファイルに書き込む
open(COMMENT_OUT,">${int_dir}_one/_idone/${pmfile}/${file}_ocm.cgi");
print COMMENT_OUT "$top_line$line";
close(COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${file}_ocm.cgi");

# 追加する行（全コメントファイル）
if($secret_flag){ $key_newcom = 4; } else{ $key_newcom = 1; }
$line_all .= qq(1<><>$date<>$xip<>$cnumber<>\n);
$line_all .= qq($key_newcom<>$in{'comment'}<>$date<>$i<>$file<>$put_category<>$newcolor<>\n);

# 全コメントファイルを開く
open(ALL_COMMENT_IN,"${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");
my $top_allcomment = <ALL_COMMENT_IN>;
while(<ALL_COMMENT_IN>){
$i_all++;
if($i_all > $maxall){ next; }
my($key,$comment,$date) = split(/<>/,$_);
$line_all .= $_;
}
close(ALL_COMMENT_IN);

# 全コメントファイルに書き込む
open(ALL_COMMENT_OUT,">${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");
print ALL_COMMENT_OUT $line_all;
close(ALL_COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");

# 追加する行（新着コメントファイル）
if($secret_flag){ $put_newcomment_key = 4; }
elsif($pure_flag && $mainnews_base ne "2"){ $put_newcomment_key = 1; }
else{ $put_newcomment_key = 3; }
$line_new .= qq($put_newcomment_key<>$in{'comment'}<>$date<>$pmfile<>$file<>$put_category<>$name_base<>\n);

# 新着コメントファイルを開く
open(NEW_COMMENT_IN,"${int_dir}_one/new_comment.cgi");
while(<NEW_COMMENT_IN>){
$i_new++;
if($i_new >= $maxnew){ last; }
$line_new .= $_;
}
close(NEW_COMMENT_IN);

# 新着コメントファイルに書き込む
open(NEW_COMMENT_OUT,">${int_dir}_one/new_comment.cgi");
print NEW_COMMENT_OUT $line_new;
close(NEW_COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/new_comment.cgi");

# 基本ファイルに書き込む
$line_base = qq($key_base<>$num_base<>$name_base<>$trip_base<>$id_base<>$account_base<>$itrip_base<>$file<>$viewtime_base<>$mainnews_base<>$news_base<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
print BASE_OUT $line_base;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");

# ロック解除
&unlock("${pmfile}ONE") if $lockkey;

# リダイレクト（ローカル）
if($alocal_mode){
if($in{'back'} eq "all"){ print qq(location:$sciript?mode=view-$pmfile-all-1\n\n); exit; }
print qq(location:$sciript?mode=view-$pmfile-$file-1\n\n);
}
# リダイレクト（ウェブ）
if($in{'back'} eq "all"){ print qq(location:view-$pmfile-all-1.html\n\n); exit; }
print qq(location:view-$pmfile-$file-1.html\n\n);

exit;

1;
