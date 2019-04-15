
# 局所化
my($line,$view_comment,$flag,$color_select,$newcolor);

# CSS定義
$css_text .= qq(
.input_text{width:30em;}
);

# BodyタグのJavaScript
$body_javascript = qq( onload="document.form1.comment.focus()");

# ファイル定義
my $file = $in{'account'};
$file =~ s/[^a-z0-9]//g;
if($file eq ""){ &error("アカウントが存在しません。"); }

# 汚染チェック
my $num = $in{'num'};
$num =~ s/\D//g;
if($num eq ""){ &error("編集するカテゴリを指定してください。"); }

my $res = $in{'res'};
$res =~ s/\D//g;
if($res eq ""){ &error("編集するナンバーを指定してください。"); }

# 基本ファイルを開く
&base_open($file);

# エラー
if($key_base ne "1"){ &error("ページが存在しません。"); }
if($file ne $pmfile && !$myadmin_flag){ &error("自分ではありません。"); }

# コメントファイルを開く
open(DATA_IN,"${int_dir}_one/_idone/$file/${num}_ocm.cgi") || &error("ページが存在しません。");
my $top_data = <DATA_IN>;
my($key_ocm,$sub_ocm,$date_ocm,$xip_ocm,$cnumber_ocm,$host_ocm,$guide_ocm) = split(/<>/,$top_data);

# キーによって処理変更
if($key_ocm eq "2"){ &error("このカテゴリは削除済みです。"); }

# 編集内容を定義
my $new_comment = $in{'comment'};

# 色のチェック
if($in{'color'}){
$newcolor = $in{'color'};
$newcolor =~ s/\W//g;
if(length($newcolor) > 3){ &error("色指定が変です。"); }
}

# コメントファイル展開
while(<DATA_IN>){
chomp $_;
my($key,$comment,$date,$res2,$color) = split(/<>/,$_);
if( ($key eq "1" || $key eq "4") && $res2 eq $res){ $view_comment = qq($comment); $view_color = $color; $comment = $new_comment; $color = $newcolor; $flag = 1; }
$line .= qq($key<>$comment<>$date<>$res2<>$color<>\n);
}
close(DATA_IN);

# エラー
if(!$flag){ &error("コメントがありません。"); }

# 編集実行
if($postflag && $in{'action'}){ &edit_comment; }


# 強調色の定義
$color_select .= qq(<select name="color"><option value="">強調);
foreach(@color){
my($name,$code) = split(/=/,$_);
if($view_color eq $code){ $color_select .= qq(<option value="$code" style="color:#$code;" selected>$name\n); }
else{ $color_select .= qq(<option value="$code" style="color:#$code;">$name\n); }
}
$color_select .= qq(</select>);


# HTML
my $print = qq(
<h1>編集</h1>

<a href="view-$file-$num-1.html">$sub_ocm</a> &gt; No.$res<br><br>

<form action="$action" method="post" name="form1"$sikibetu>
<div>
<input type="text" name="comment" value="$view_comment" class="input_text">
$color_select

<input type="hidden" name="mode" value="ecm">
<input type="hidden" name="num" value="$num">
<input type="hidden" name="res" value="$res">
<input type="hidden" name="account" value="$file">
<input type="submit" name="action" value="編集する">

</div>
</form>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;

#-----------------------------------------------------------
# 内容編集
#-----------------------------------------------------------

sub edit_comment{

# 局所化
my($line_allocm);

# 投稿制限
&axscheck;

# 各種チェック
require "${int_dir}regist_allcheck.pl";
&length_check($in{'comment'},"内容",500,1);
&url_check("",$in{'comment'});
&error_view;

# ロック開始
&lock("${file}ONE") if $lockkey;

# コメントファイルを書き込む
open(OCM_OUT,">${int_dir}_one/_idone/$file/${num}_ocm.cgi") || &error("ページが存在しません。");
print OCM_OUT "$top_data$line";
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/$file/${num}_ocm.cgi");

# 全コメントファイルを開く
open(ALLOCM_IN,"${int_dir}_one/_idone/$file/all_ocm.cgi");
my $top_allocm = <ALLOCM_IN>;
while(<ALLOCM_IN>){
chomp $_;
my($key,$comment,$date,$res2,$num2,$category,$color) = split(/<>/,$_);
if($res2 eq $res && $num2 eq $num){ $comment = $new_comment; $color = $newcolor; }
$line_allocm .= qq($key<>$comment<>$date<>$res2<>$num2<>$category<>$color<>\n);
}
close(ALLOCM_IN);

# 全コメントファイルを書き込む
open(OCM_OUT,">${int_dir}_one/_idone/$file/all_ocm.cgi");
print OCM_OUT "$top_allocm$line_allocm";
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/$file/all_ocm.cgi");


# ロック解除
&unlock("${file}ONE") if $lockkey;

if($alocal_mode){  print "location:$script?mode=view-$file-$num-1\n\n"; }
else{ print "location:view-$file-$num-1.html\n\n"; }

exit;

}

1;
