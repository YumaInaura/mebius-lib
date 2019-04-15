package main;

#-----------------------------------------------------------
# お気に入り処理
#-----------------------------------------------------------
sub bbs_mylist{

# タイトル定義
$sub_title = "お気に入り登録";
$head_link3 = " &gt; お気に入り登録";

# 携帯モード
if($in{'k'}){ &kget_items(); }

# お気に入り最大登録数
$max_add = 25;

# 送信先定義
if($alocal_mode){ $action = "$script"; } else { $action = "./"; }
# モード振り分け
if($in{'type'} eq "delete"){ &delete_mylist(); }
else{ &add_list(); }

# エラー
if($cnumber eq ""){ &error("この環境ではページが利用できません。"); }
}

#-----------------------------------------------------------
# お気に入り記事を登録する
#-----------------------------------------------------------

sub add_list{

# 局所化
my($line,$file,$no);

# ファイル定義
$file = $cnumber;
$file =~ s/\W//g;
if($cmfile){ $file = $cmfile; }
if($file eq ""){ &error("設定値が変です。"); }

# 汚染チェック
$no = $in{'no'};
$no =~ s/\D//g;
if($no eq ""){ &error("設定値が変です。"); }

# 追加する行
$line = qq(1<>$no<>$moto<>\n);

# ロック開始
&lock("cnumber") if($lockkey);

# ファイルを開く
open(CNUMBER_IN,"${int_dir}_cnumber/$file/${file}_mylist.cgi");
while(<CNUMBER_IN>){
$i++;
if($i < $max_add){
my($key2,$no2,$moto2) = split(/<>/,$_);
if($no2 ne $no || $moto2 ne $moto){ $line .= $_; }
}
}
close(CNUMBER_IN);

# ファイルを書き出す
Mebius::Mkdir("","${int_dir}_cnumber/$file",$dirpms);
open(CNUMBER_OUT,">${int_dir}_cnumber/$file/${file}_mylist.cgi");
print CNUMBER_OUT $line;
close(CNUMBER_OUT);
Mebius::Chmod(undef,"${int_dir}_cnumber/$file/${file}_mylist.cgi");

# ロック解除
&unlock("cnumber") if($lockkey);

# メール配信リストへ移行する場合
if($in{'to_mylist'}){ &to_mylist; }

# リダイレクト
if($in{'my'}){
if($alocal_mode){ print "location:main.cgi?mode=my$kreq2#MYLIST\n\n"; }
else{ print "location:http://$server_domain/_main/?mode=my$kreq2#MYLIST\n\n"; }
}

# ジャンプ
$jump_sec = 1;
$jump_url = "/_main/?mode=my$kreq1#MYLIST";
if($alocal_mode){ $jump_url = "main.cgi?mode=my$kreq1#MYLIST"; }

# ヘッダ
main::header();

# HTML
print qq(
<div class="body1">
お気に入り登録をしました。（<a href="$jump_url">マイページへ</a>）
</div>
);

# フッタ
&footer();

exit;

}



#-----------------------------------------------------------
# お気に入り記事を削除する
#-----------------------------------------------------------
sub delete_mylist{

# 局所化
my($line,$file,$no,$bbs);
our(%in);

# ファイル定義
$file = $cnumber;
$file =~ s/\W//g;
if($cmfile){ $file = $cmfile; }
if($file eq ""){ &error("設定値が変です。"); }

# 汚染チェック
$no = $in{'no'};
$no =~ s/\D//g;
if($no eq ""){ &error("設定値が変です。"); }

# 汚染チェック
$bbs = $in{'bbs'};
$bbs =~ s/\W//g;
if($bbs eq ""){ &error("設定値が変です。"); }

# ロック開始
&lock("cnumber") if($lockkey);

# ファイルを開く
open(CNUMBER_IN,"${int_dir}_cnumber/$file/${file}_mylist.cgi");
while(<CNUMBER_IN>){
my($key2,$no2,$moto2) = split(/<>/,$_);
if($moto2 eq $bbs && $no2 eq $no){ next; }
$line .= $_;
}
close(CNUMBER_IN);

# ファイルを書き出す
open(CNUMBER_OUT,">${int_dir}_cnumber/$file/${file}_mylist.cgi");
print CNUMBER_OUT $line;
close(CNUMBER_OUT);
Mebius::Chmod(undef,"${int_dir}_cnumber/$file/${file}_mylist.cgi");

# ロック解除
&unlock("cnumber") if($lockkey);

# リダイレクト
if($alocal_mode){ print "location:main.cgi?mode=my$kreq2#MYLIST\n\n"; }
else{ print "location:http://$server_domain/_main/?mode=my$kreq2#MYLIST\n\n"; }

exit;

}

1;

