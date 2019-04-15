
package main;

#-----------------------------------------------------------
# ＳＮＳタグの削除
#-----------------------------------------------------------
sub auth_deletetag{

# 局所化
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$line2,$i,$flag,$filehandle1);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ファイルオープン
&open($file);

# キーワードのエンコード
$enc_tag = Mebius::Encode("",$submode3);

# 各種エラー
if(!$myprof_flag && !$myadmin_flag){ &error("他メンバーのタグは削除できません。"); }
if($enc_tag eq ""){ &error("削除するキーワードを指定してください。"); }

# ロック開始
&lock("auth$file") if($lockkey);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# マイタグファイルを開く
my $openfile1 = "${account_directory}${file}_tag.cgi";
open(MYTAG_IN,"<","$openfile1");
while(<MYTAG_IN>){
my($key2,$tag2) = split(/<>/,$_);
if($tag2 eq $submode3){ $flag = 1; next; }
$line .= $_;
}
close(MYTAG_IN);

# マイタグファイルを書き込む
Mebius::Fileout(undef,$openfile1,$line);

# ロック解除
&unlock("auth$file") if($lockkey);

# ロック開始
&lock("tag$enc_tag") if($lockkey);

# キーワードファイルを開く
my($i_wordfile);
my $openfile2 = "${auth_log_directory}_tag/$enc_tag.cgi";
open($filehandle1,"<","$openfile2");
	while(<$filehandle1>){
	my($deleter);
	my($key,$account,$name,$comment,$deleter) = split(/<>/,$_);


		# 削除したい行がヒットした場合
		if($account eq $file){

			$flag = 1; 

			# 管理者削除の場合、ペナルティを追加
			if($myadmin_flag && $in{'penalty'}){
				Mebius::Authpenalty("Penalty",$account,$comment,"SNSタグ - $submode3");
				# SNSペナルティ
				Mebius::AuthPenaltyOption("Penalty",$account,6*60*60);
			}

				next;

		}

	$line2 .= $_;
	$i_wordfile++;
	}
close($filehandle1);

# キーワードファイルを書き込む
Mebius::Fileout("",$openfile2,$line2);

# ロック解除
&unlock("tag$enc_tag") if($lockkey);

# 行がなくなった場合、全タグファイルから削除
if(!$i_wordfile){ &delete_alltag; }

# ロック開始
&lock("newtag") if($lockkey);

# 新着タグファイルを開く
my $openfile3 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"$openfile3");
while(<NEWTAG_IN>){
chomp $_;
my($notice,$tag,$account) = split(/<>/,$_);
if($notice < 5 && $file eq $account && $tag eq $submode3){ next; }
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


# 削除対象が存在しなかった場合
if(!$flag){ &error("削除できませんでした。既に削除済みか、登録のないキーワードです。"); }

if($myadmin_flag){ Mebius::Redirect("","${auth_url}tag-word-$enc_tag.html"); }

# ページジャンプ
$jump_sec = $auth_jump;
$jump_url = "${file}/tag-view";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }


my $print = qq(
タグを削除しました（<a href="$jump_url">→タグ登録ページへ</a>）。<br>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# 全タグファイルを更新
#-----------------------------------------------------------
sub delete_alltag{

# 局所化
my($line4);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ロック開始
&lock("alltag") if($lockkey);

# 全タグファイルを開く
my $openfile4 = "${$auth_log_directory}alltag.cgi";
open(ALLTAG_IN,"<",$openfile4);
	while(<ALLTAG_IN>){
		chomp;
			if($_ eq $submode3){ next; }
		$line4 .= qq($_\n);
	}
close(ALLTAG_IN);

# 全タグファイルを書き込む
open(ALLTAG_OUT,">",$openfile4);
print ALLTAG_OUT $line4;
close(ALLTAG_OUT);
Mebius::Chmod(undef,$openfile4);

# ロック解除
&unlock("alltag") if($lockkey);

}

1;
