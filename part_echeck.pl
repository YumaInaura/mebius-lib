
use strict;

#-----------------------------------------------------------
# 投稿文章を記録
#-----------------------------------------------------------
sub do_echeck{

# 宣言
my($type,$echeck_flag) = @_;
my($line,$echeck_com,$file,$comment);
our($int_dir,$logpms,$moto,$server_domain,%in);
our($agent,$addr,$date,$i_handle,$i_resnumber,$realmoto,$int_dir,$newno,%in);
our($pmname);

# 汚染チェック
$echeck_flag =~ s/\W//g;
if($echeck_flag eq ""){ return; }

# 投稿文章を記録
$comment = $in{'comment'};
$comment =~ s/<br>/\n/g;

# 記録する内容
$line .= <<"EOM";
http://$server_domain/jak/${moto}.cgi?mode=view&no=$in{'res'}#S$in{'resnum'}
$in{'name'} ( $pmname )	$date	$addr
$agent
$comment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOM

# ファイル定義
$file = "${int_dir}_echeck/${echeck_flag}_echeck.log";

# ファイルを書き込み
open(KIROKU_OUT,">>$file");
print KIROKU_OUT $line;
close(KIROKU_OUT);
chmod($logpms,$file);

# 一定確率でファイルを削除
if(rand(250) < 1){ unlink($file); }

}


1;
