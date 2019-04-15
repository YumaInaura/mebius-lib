
# 局所化
my($select_line,$form,$line,$navi_line,$category_line,$view_category,$base_form);

# CSS定義
$css_text .= qq(
hr{border-top:1px #088 solid;border-bottom:1px #fff solid;}
.category_list{font-size:90%;word-spacing:0.3em;line-height:1.3em;}
.guide{color:#070;font-size:90%;}
);

# ファイル定義
my $file = $submode2;
$file =~ s/[^0-9a-z]//g;
if($file eq ""){ &error("ページが存在しません。"); }

# ログインしていない場合
if(!$idcheck){ &error("このページを利用するには<a href=\"$auth_url\">メビリンＳＮＳ</a>にログインした後で、もう１回アクセスしてください。"); }

# 自分でない場合
if($pmfile ne $file && !$myadmin_flag){ &error("自分ではありません。"); }

# 編集実行
if($in{'action'} eq "base_edit"){ &action_edit; }

# 基本ファイルを開く
&base_open($file);

# 登録開始してない場合
if($key_base ne "1" && !$myadmin_flag){ &error("登録開始してください。"); }

# カテゴリリスト調整（１）
$navi_line .= qq( <a href="view-$submode2-all-1.html">全カテゴリ</a>);

# カテゴリ記録ファイルを開く
open(CATE_IN,"${int_dir}_one/_idone/${file}/${file}_cate.cgi");
while(<CATE_IN>){
my($category,$num) = split(/<>/,$_);
$select_line .= qq(<option value="$category">$category);
$navi_line .= qq( <a href="view-$file-$num-1.html">$category</a>);
push(@now_category,$category);
#$category_line .= qq(<li><a href="view-$submode2-$num.html">$category</a> );
}
close(CATE_IN);

# カテゴリリスト調整（２）
$navi_line .= qq( <span class="red">設定</span>);
if($navi_line){ $navi_line = qq(<div class="category_list">カテゴリ： $navi_line</div>); }
#$category_line = qq(<h3>現在のカテゴリ</h3><ul>$category_line</ul>);

# 自分のアカウントの場合、フォームを取得
if($pmfile eq $submode2 || $myadmin_flag){ &one_edit_get_form(); }

# リンクなどの表示調整
my $name_view = $name_base;
if($trip_base){ $name_view = qq($name_view☆$trip_base); }
#if($account_base){ $account_link = qq( / アカウント： <a href="${auth_url}$account_base/">$account_base</a> ); }

# タイトル定義
$sub_title = qq($view_category$name_base - $title);

# HTML
my $print = qq(
<h1>設定： $name_viewの$title</h1>
$navi_line
$account_link
$base_form
$form
$line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

#-----------------------------------------------------------
# 設定フォーム
#-----------------------------------------------------------
sub one_edit_get_form{

# 局所化
my($viewtime_checked,$input_trip,$input_lock,$lock_checked,$input_mainnews);

# チェック定義
if($viewtime_base eq "1"){ $viewtime_checked = " checked"; }

# 基本設定フォーム
if($itrip_base ne ""){ $input_trip = qq(#$itrip_base); }

# 管理設定
if($myadmin_flag){
if($key_base eq "2"){ $input_lock .= qq(<br><input type="checkbox" name="unlock" value="1"> アカウントをロック解除（管理者設定） 現在のキー： $key_base); }
else{ $input_lock .= qq(<br><input type="checkbox" name="lock" value="1"> アカウントをロック（管理者設定） 現在のキー： $key_base); }
if($mainnews_base eq "2"){ $input_mainnews .= qq(<input type="checkbox" name="mainnews_unlock" value="1"> 公式カテゴリの新着掲載を解除（管理者設定） 現在のキー： $mainnews_base); }
else{ $input_mainnews .= qq(<input type="checkbox" name="mainnews_lock" value="1"> 公式カテゴリの新着掲載をロック（管理者設定） 現在のキー： $mainnews_base); }
}

$base_form .= qq(
<h2>基本設定</h2>
<form action="$action" method="post"$sikibetu>
<div>
筆名： <input type="text" name="name" value="$name_base$input_trip">
<input type="checkbox" name="viewtime" value="1"$viewtime_checked> 時刻を表\示する
<input type="submit" value="この内容で設定する">
$input_lock
$input_mainnews
<input type="hidden" name="mode" value="edit-$file">
<input type="hidden" name="action" value="base_edit">
$actioned_text
</div>
</form>
);

# 基本カテゴリ展開
$base_category .= qq(<h3 class="red">公式カテゴリ</h3><ul>);
foreach(@base_category){
my($category,$guide) = split(/=/,$_);
my($flag);
foreach(@now_category){ if($_ eq $category){ $flag = 1; } }

$base_category .= qq(<li>$category - <span class="guide">$guide</span>);

if($flag){
$base_category .= qq(（ 追加済みです ）)
}
else{
my $enc_category = $category;
$enc_category =~ s/(\W)/'%' . unpack('H2', $1)/eg;
$enc_category =~ s/\s/+/g;
$base_category .= qq(（ <a href="$script?mode=make_category&amp;account=$file&amp;category=$enc_category">→このカテゴリを追加</a> ）)
}
}
$base_category .= qq(</ul>);

# カテゴリ登録フォーム
$form = qq(
<h2>カテゴリ設定</h2>
$base_category
<h3>カテゴリ追加 (フリーワード)</h3>
<form action="$action" method="post"$sikibetu>
<div>
カテゴリ名： 
<input type="text" name="category" value="">
<input type="submit" value="このカテゴリを追加する">
<input type="hidden" name="mode" value="make_category">
<input type="hidden" name="account" value="$file">
<input type="checkbox" name="type" value="secret"> シークレットモード

</div>
</form>
);



}

#-----------------------------------------------------------
# 編集実行
#-----------------------------------------------------------
sub action_edit{

# 局所化
my($viewtime);

# 各種エラー
if(!$postflag){ &error("GET送信は出来ません。"); }

# トリップ取得
&trip($in{'name'});

# ID取得
&id("ACCOUNT");

# 投稿制限
&axscheck("ACCOUNT");

# 各種チェック
require "${int_dir}regist_allcheck.pl";
($in{'name'}) = shift_jis(Mebius::Regist::name_check($in{'name'}));

# エラーを表示
&error_view;

# 登録内容のチェック
if($in{'viewtime'}){ $viewtime = 1; } else { $viewtime = 2; }

# ロック開始
&lock("${file}ONE") if $lockkey;

# 基本ファイルを開く
&base_open($file);

# 登録開始してない場合
if($key_base ne "1" && !$myadmin_flag){ &error("登録開始してください。"); }

# アカウントロックの場合
if($myadmin_flag){
if($in{'lock'}){ $key_base = 2; }
if($in{'mainnews_lock'}){ $mainnews_base = 2; }
if($in{'unlock'}){ $key_base = 1; }
if($in{'mainnews_unlock'}){ $mainnews_base = 1; }
}


# 基本ファイルを書き込む
my $line = qq($key_base<>$num_base<>$i_handle<>$enctrip<>$encid<>$file<>$i_trip<>$lastnum_base<>$viewtime<>$mainnews_base<>$news_base<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${file}/${file}_base.cgi");
print BASE_OUT $line;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${file}/${file}_base.cgi");

# ロック解除
&unlock("${file}ONE") if $lockkey;

# 変更しました～のテキスト
$actioned_text = qq(<strong class="red">※設定を変更しました。</strong>);

}

1;
