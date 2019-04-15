
# カテゴリ名の最大文字数
my $maxlength = 20;
# カテゴリ説明の最大文字数
my $maxcatelength = 200;

# 局所化
my($line,$flag,$line_all,$i_all,$file,$put_category,$line_new,$put_date,$upcate_line);

# 各種エラー
if(!$postflag){ &error("GET送信は出来ません。"); }
if(!$idcheck){ &error("書き込むにはログイン（または<a href=\"start.html\">新規登録</a>）してください。"); }

# 投稿制限
($host) = &axscheck();

# 各種エラー
require "${int_dir}regist_allcheck.pl";
($in{'new_category'}) = &base_change($in{'new_category'});
&length_check($in{'new_category'},"カテゴリ名",$maxlength,1);
&url_check("",$in{'new_category'});
&error_view;

# 説明文のチェック
if($in{'guide'}){
($in{'guide'}) = &base_change($in{'guide'});
&length_check($in{'guide'},"カテゴリ説明",$maxcatelength,0);
&url_check("",$in{'guide'});
}

# ファイル定義１
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;
if(!$file){ &error("データが変です。"); }
if($file ne $pmfile && !$myadmin_flag){ &error("自分ではありません。"); }

# ファイル定義２
$num = $in{'num'};
$num =~ s/\D//g;
if(!$num){ &error("データが変です。"); }

# ロック開始
&lock("${file}ONE") if $lockkey;

# 基本ファイルを開く
&base_open($file);

# ファイルがない場合
if($key_base ne "1"){ &error("ファイルが存在しません。"); }

# 新カテゴリの処理
my $new_category = $in{'new_category'};

# コメントファイルを開く
my($i);
open(COMMENT_IN,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi");
my $top_comment = <COMMENT_IN>;
chomp $top_comment;
my($key_ocm,$sub_ocm,$date_ocm,$xip_ocm,$cnumber_ocm,$host_ocm,$guide_ocm) = split(/<>/,$top_comment);
while(<COMMENT_IN>){ $line .= $_; }
close(COMMENT_IN);

# 削除済みの場合
if($key_ocm eq "2"){ &error("削除済みのカテゴリです。"); }

# カテゴリ閉鎖前のプレビュー
if($in{'close'} && !$in{'break'}){ &preview_close; }

# キー変更
if($in{'close'}){ $key_ocm = 2; }

# カテゴリファイルを開く
open(CATE_IN,"${int_dir}_one/_idone/${file}/${file}_cate.cgi");
while(<CATE_IN>){
chomp $_;
my($category,$num2,$key) = split(/<>/,$_);

if($category eq $in{'new_category'} && $sub_ocm ne $in{'new_category'}){ &error("このカテゴリは登録済みです。"); }
if($num2 eq $num){
$flag = 1;
if($in{'close'}){ next; }
$category = $new_category;
if($in{'up'}){ $upcate_line = qq($category<>$num2<>$key<>\n); next; }
}
$cate_line .= qq($category<>$num2<>$key<>\n);
}
close(CATE_IN);
if(!$flag){ &error("カテゴリが存在しません。"); }

# 追加する行（コメントファイル）
my $top_line .= qq($key_ocm<>$new_category<>$date<>$xip<>$cnumber<>$host<>$in{'guide'}<>\n);

# コメントファイルに書き込む
open(COMMENT_OUT,">${int_dir}_one/_idone/${file}/${num}_ocm.cgi");
print COMMENT_OUT "$top_line$line";
close(COMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${num}_ocm.cgi");

# カテゴリファイルに書き込む
open(CATE_OUT,">${int_dir}_one/_idone/${file}/${file}_cate.cgi");
print CATE_OUT "$upcate_line$cate_line";
close(CATE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${file}_cate.cgi");

# 削除済みカテゴリファイルを開く
my $delcate_line .= qq($sub_ocm<>${file}<>\n);
if($in{'close'}){
open(DELCATE_IN,"${int_dir}_one/_idone/${file}/${file}_delcate.cgi");
while(<DELCATE_IN>){ $delcate_line .= $_; }
close(DELCATE_IN);
}

# 削除済みカテゴリファイルに書き込む
if($in{'close'}){
open(DELCATE_OUT,">${int_dir}_one/_idone/${file}/${file}_delcate.cgi");
print DELCATE_OUT "$delcate_line";
close(DELCATE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${file}_delcate.cgi");
}

# 全コメントファイルを開く（カテゴリ閉鎖の場合）
my($allocm_line,$top_allocm);
if($in{'close'}){
open(ALLOCM_IN,"${int_dir}_one/_idone/${file}/all_ocm.cgi");
$top_allocm = <ALLOCM_IN>;
while(<ALLOCM_IN>){
chomp $_;
my($key,$comment,$date,$res,$num2,$category) = split(/<>/,$_);
if($num2 eq $num){ $key = 2; }
$allocm_line .= qq($key<>$comment<>$date<>$res<>$num2<>$category<>\n);
}
close(ALLOCM_IN);
}

# 削除済みカテゴリファイルに書き込む（カテゴリ閉鎖の場合）
if($in{'close'}){
open(ALLOCM_OUT,">${int_dir}_one/_idone/${file}/all_ocm.cgi");
print ALLOCM_OUT "$top_allocm$allocm_line";
close(ALLOCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/all_ocm.cgi");
}


# ロック解除
&unlock("${file}ONE") if $lockkey;

# リダイレクト
if($in{'close'}){
if($alocal_mode){ print qq(location:$script?mode=view-$file-all-1\n\n); }
print qq(location:view-$file-all-1.html\n\n);
}

if($alocal_mode){ print qq(location:$script?mode=view-$file-$num-1\n\n); }
print qq(location:view-$file-$num-1.html\n\n);

#-----------------------------------------------------------
# カテゴリ閉鎖前のプレビュー
#-----------------------------------------------------------
sub preview_close{


# ロック解除
&unlock("${file}ONE") if $lockkey;


$css_text .= qq(
li{color:#f00;}
);


my $print = qq(
<h1>カテゴリ削除</h1>

<form action="$action" method="post"$sikibetu>
<div>
<a href="view-$pmfile-$in{'num'}-1.html">$sub_ocm</a>のカテゴリを削除する前に、次の説明をご覧ください。

<br>
<br>

<strong class="red">★ご注意</strong>
<br><br>
<ul>
<li><strong>カテゴリ内のコメントも全て削除されます。</strong>
<li><strong>１度削除したカテゴリは、元には戻せません。</strong>
</ul>
<br>

よろしいですか？<br><br>
<input type="checkbox" name="break" value="1"> はい、問題ありません。
<input type="hidden" name="mode" value="change_category">
<input type="hidden" name="new_category" value="$sub_ocm">
<input type="hidden" name="guide" value="$guide_ocm">
<input type="hidden" name="num" value="$in{'num'}">
<input type="hidden" name="account" value="$in{'account'}">
&nbsp;<input type="submit" value="カテゴリを閉鎖する">
<input type="hidden" name="close" value="1">
</div>
</form>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
