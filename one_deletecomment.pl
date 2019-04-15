
# 局所化
my($line,$flag,$line_allocm,$check_date);

# 確認
#if(!$in{'do'}){ &preview; }

# ファイル定義１
my $file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("ページが存在しません。"); }

# ファイル定義２
my $num = $in{'num'};
$num =~ s/\D//g;
if($num eq ""){ &error("削除するカテゴリを指定してください。"); }

# ファイル定義３
my $res = $in{'res'};
$res =~ s/\D//g;
if($res eq ""){ &error("削除するナンバーを指定してください。"); }

# 自分のアカウントではない場合
if($pmfile ne $file && !$myadmin_flag){ &error("自分じゃありません。"); }

# ロック開始
&lock("${pmfile}ONE") if $lockkey;

# 基本ファイルを開く
&base_open($file);

# コメントファイルを開く
open(OCM_IN,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi") || &error("ページが存在しません。");
my $top_data = <OCM_IN>;
while(<OCM_IN>){
chomp $_;
my($key,$comment,$date,$res2,$color) = split(/<>/,$_);
if($key eq "1" && $res2 eq $res){ $flag = 1; $key = 2; }
if($key eq "4" && $res2 eq $res){ $flag = 1; $key = 5; }
$line .= qq($key<>$comment<>$date<>$res2<>$color<>\n);
}
close(OCM_IN);

# 全コメントファイルを開く
open(ALLOCM_IN,"${int_dir}_one/_idone/${file}/all_ocm.cgi");
my $top_data_allocm = <ALLOCM_IN>;
while(<ALLOCM_IN>){
chomp $_;
my($key,$comment,$date,$res2,$num2,$category2,$color) = split(/<>/,$_);
if($key eq "1" && $res2 eq $res && $num2 eq $num){ $check_date = $date; $key = 2; $flag = 1; }
if($key eq "4" && $res2 eq $res && $num2 eq $num){ $check_date = $date; $key = 5; $flag = 1; }
$line_allocm .= qq($key<>$comment<>$date<>$res2<>$num2<>$category2<>$color<>\n);
}
close(ALLOCM_IN);

# 削除する内容がなかった場合
if(!$flag){ &error("削除する内容がありません。"); }

# コメントファイルを書き込む
open(OCM_OUT,">${int_dir}_one/_idone/${file}/${num}_ocm.cgi");
print OCM_OUT "$top_data$line";
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi");

# 全コメントファイルを書き込む
open(ALLOCM_OUT,">${int_dir}_one/_idone/${file}/all_ocm.cgi");
print ALLOCM_OUT "$top_data_allocm$line_allocm";
close(ALLOCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/all_ocm.cgi");

# 新着コメントファイルを開く
open(NEW_COMMENT_IN,"${int_dir}_one/new_comment.cgi");
while(<NEW_COMMENT_IN>){
chomp $_;
my($key,$comment,$date,$account,$num2,$category,$name) = split(/<>/,$_);
if($account eq $file && $num2 eq $num && $date eq $check_date){
if($key eq "1" || $key eq "3"){ $key = 2; }
}
$line_new .= qq($key<>$comment<>$date<>$account<>$num2<>$category<>$name<>\n);
}
close(NEW_COMMENT_IN);

# 新着コメントファイルに書き込む
open(NEW_COMMENT_OUT,">${int_dir}_one/new_comment.cgi");
print NEW_COMMENT_OUT $line_new;
close(NEW_COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/new_comment.cgi");

# ロック解除
&unlock("${pmfile}ONE") if $lockkey;

# ジャンプ先定義
if($alocal_mode){
if($in{'back'} eq "all"){ $jump_url = "$script?mode=view-$file-all-1"; }
else{ $jump_url = "$script?mode=view-$file-$num-1"; }
}
else{
if($in{'back'} eq "all"){ $jump_url = "view-$file-all-1.html"; }
else{ $jump_url = "view-$file-$num-1.html"; }
}

# リダイレクト
print "location:$jump_url\n\n";

exit;


#-----------------------------------------------------------
# 削除前の確認
#-----------------------------------------------------------
sub preview{

my $print = qq(
<a href="$script?mode=del&amp;account=$in{'account'}&amp;num=$in{'num'}&amp;res=$in{'res'}&amp;do=1">削除する</a>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}

1;
