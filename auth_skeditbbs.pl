
package main;


#-----------------------------------------------------------
# BBSのレスを操作
#-----------------------------------------------------------
sub auth_skeditbbs{

# 局所化
my($file,$open,$line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$newkey);

# 値が間違っている場合
if($in{'decide'} ne "delete" && !$myadmin_flag){ &error("値を正しく指定してください。"); }

# 汚染チェック１
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("データ指定が変です。"); }

# 汚染チェック２
$open = $in{'num'};
$open =~ s/\D//g;
if($open eq ""){ &error("データ指定が変です。"); }

# 汚染チェック３
$number = $in{'number'};
$number =~ s/\D//g;
if($number eq ""){ &error("データ指定が変です。"); }

# ログインしていない場合
if(!$idcheck){ &error("記事を削除するには、ログインしてください。"); }

# プロフィールを開く
&open($file);

# ディレクトリ定義
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ファイル定義
my $bbs_thread_file = "${account_directory}bbs/${file}_bbs_${open}.cgi";

# ロック開始
&lock("auth$file") if $lockkey;

# 記事単体ファイルを開く
open(BBS_IN,"<",$bbs_thread_file)||&error("記事が開けません。");
$top1 = <BBS_IN>;
$line .= $top1;

chomp $top1;
my($key,$num,$sub,$res,$dates,$newtime,$restime) = split(/<>/,$top1);
my($year,$month,$day,$hour,$min) = split(/,/,$dates);
$top1res = $res;

while(<BBS_IN>){
chomp $_;
my($key,$num,$account,$name,$trip,$id,$comment,$dates,$restime,$resxip) = split(/<>/,$_);

# キー変更処理
if($num eq $number){
&open($account,"nocheck");
if($ppadmin && !$myadmin_flag){ &error("管理者投稿は削除できません。"); }
if($key eq "1"){
if($account eq $pmfile){ $key = 3; $flag = 1; }
elsif($file eq $pmfile){ $key = 2; $flag = 1; }
elsif($myadmin_flag){ $key = 4; $flag = 1; $deleter = qq($pmfile<>$pmname<>); $flag = 1; }
}
elsif($in{'decide'} eq "revive" && $myadmin_flag){ $key = 1; $deleter = qq($pmfile<>$pmname<>); $flag = 1; }
$line .= qq($key<>$num<>$account<>$name<>$trip<>$id<>$comment<>$dates<>$restime<>$resxip<>$deleter\n);
}

else { $line .= qq($_\n); }

}
close(BBS_IN);


# 該当行がない場合
if(!$flag){ &error("実行できませんでした。"); }

# 記事単体ファイルを書き出し
Mebius::Fileout(undef,$bbs_thread_file,$line);

# ロック解除
&unlock("auth$file") if $lockkey;

# ジャンプ先定義
$jump_sec = $auth_jump;
$jump_url = "$file/b-$in{'num'}#S$number";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }


# HTML
my $print = <<"EOM";
実行しました。<a href="$jump_url">記事</a>に移動します。
EOM


Mebius::Template::gzip_and_print_all({},$print);


# 終了
exit;

}


1;
