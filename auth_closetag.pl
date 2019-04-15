
package main;

#-----------------------------------------------------------
# SNSタグを閉鎖
#-----------------------------------------------------------

sub auth_closetag{

# 局所化
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$file2);

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# エラー
if(!$myadmin_flag){ &error("ページが存在しません。[aclst]");}

# エンコード
$file2 = $submode3;
#$file2 =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
#$file2 =~ tr/ /+/;
$file2 =~ s/\.//;
$file2 =~ s/\///;


# ファイルを開く
open(CLOSE_IN,"<","${auth_log_directory}_closetag/${file2}_close.cgi");
my $top = <CLOSE_IN>;
close(CLOSE_IN);
my($key,$text,$remove) = split(/<>/,$top);

# キーワード閉鎖
if($in{'type'} eq "close" ){
$line = qq(0<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);
&auth_delete_alltag();
&auth_delete_newtag();
}

# キーワードロック
elsif($in{'type'} eq "lock" ){
my($put_key);
if($key eq "2"){ $put_key = 1; }
else{ $put_key = 2;  }

$line = qq($put_key<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);
}


# キーワード復活
elsif($in{'type'} eq "revibe"){
$line = qq(<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);
}

# コメント設定
else{
$line = qq($key<>$in{'text'}<>$remove<>\n);
open(CLOSE_OUT,">","${auth_log_directory}_closetag/${file2}_close.cgi");
print CLOSE_OUT $line;
close(CLOSE_OUT);

}

# ページジャンプ
$jump_sec = $auth_jump;
$jump_url = "./tag-word-${file2}.html";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }

# リダイレクト
if($myadmin_flag){ Mebius::Redirect("","./tag-word-${file2}.html"); }

# HTML
my $print = qq(
タグを閉鎖(または再開)しました（<a href="$jump_url">→戻る</a>）。<br>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 新着タグファイルを更新
#-----------------------------------------------------------
sub auth_delete_newtag{

# ロック開始
&lock("newtag") if($lockkey);

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# 新着タグファイルを開く
my $openfile3 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"<","$openfile3");
while(<NEWTAG_IN>){
chomp $_;
my($notice,$tag,$account) = split(/<>/,$_);
if($tag eq $file2){ next; }
$line3 .= qq($notice<>$tag<>$account<>\n);
}
close(NEWTAG_IN);

# 新着タグファイルを書き込む
open(NEWTAG_OUT,">","$openfile3");
print NEWTAG_OUT $line3;
close(NEWTAG_OUT);
Mebius::Chmod(undef,$openfile3);

# ロック解除
&unlock("newtag") if($lockkey);

}

#-----------------------------------------------------------
# 全タグファイルを更新
#-----------------------------------------------------------
sub auth_delete_alltag{

# 局所化
my($line4);

# ロック開始
&lock("alltag") if($lockkey);

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# 全タグファイルを開く
my $openfile4 = "${auth_log_directory}alltag.cgi";
open(ALLTAG_IN,"<","$openfile4");
while(<ALLTAG_IN>){
chomp;

if($_ eq $file2){ next; }
$line4 .= qq($_\n);
}
close(ALLTAG_IN);

# 全タグファイルを書き込む
open(ALLTAG_OUT,">","$openfile4");
print ALLTAG_OUT $line4;
close(ALLTAG_OUT);
Mebius::Chmod(undef,$openfile4);

# ロック解除
&unlock("alltag") if($lockkey);

}

1;
