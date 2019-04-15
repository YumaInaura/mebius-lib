


# 新着メンバー最大数
$max_comer = 10000;

# ヘッダリンク
$head_link3 = qq( &gt; 参加フォーム);

# 基本ファイルを開く
open(BASE_IN,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
my $top_base = <BASE_IN>;
my($key,$num) = split(/<>/,$top_base);
close(BASE_IN);

# 各種エラー
if($key eq "1"){ print "location:view-$pmfile-all-1.html\n\n"; exit;  &error("既に登録済みです。"); }
if($key eq "2"){ &error("このアカウントはロックされています。"); }

# 新規参加の処理
if($in{'action'}){ &action_start; }

# CSS定義
$css_text .= qq(
.alert{font-size:80%;color:#080;}
);


# HTML
my $print = qq(
<h1>$titleについて</h1>
$titleとは、カテゴリを作り、１行ずつ文章を書くことが出来るツールです。<br>
メモ、ライフログ、教訓の置き場、思考の整理場などとしてご利用ください (<a href="${guide_url}%A5%DE%A5%A4%A5%ED%A5%B0">→もっと詳しく</a>)。

<h2>$titleに参加する</h2>
<form action="$action" method="post"$sikibetu>
<div>

<input type="checkbox" name="check1" value="1"> 私は「個人情報掲載」「マナー違反」「迷惑投稿」「宣伝」など、一切の禁止事項をおこなわないことを誓います（<a href="${guide_url}/%A5%DE%A5%A4%A5%ED%A5%B0">→ルールはこちら</a>）。<br>
<input type="checkbox" name="check2" value="1"> 私はルール違反があった場合、アカウントを無条件に削除されて\構\いません。<br><br>

筆名<input type="text" name="name" value="$cnam"> <span class="alert">*筆名は後で変更できます。</span>
<input type="hidden" name="mode" value="start">
<input type="hidden" name="action" value="1">
<input type="submit" value="参加する">
</div>
</form>

);

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;

#-----------------------------------------------------------
# 新規登録処理
#-----------------------------------------------------------
sub action_start{

# 局所化
my($i_newcomer);

# トリップ作成
&trip($in{'name'});

# IDをつける
&id;

# 各種エラー
if(!$postflag){ &error("ＧＥＴ送信は出来ません。"); }
if($pmfile eq ""){ &error("アカウントが存在しません。"); }
if(length($i_handle) > 20){ &error("筆名が長すぎます。全角10文字以下で入力してください。"); }
if(!$in{'check1'} || !$in{'check2'}){ &error("登録できません。"); }

# 投稿制限
&axscheck();

# ロック開始
&lock("${pmfile}ONE") if $lockkey;

# 基本ディレクトリ作成
Mebius::Mkdir("","${int_dir}_one/_idone/${pmfile}",$dirpms);

# 基本ファイル作成
my $line_base = qq(1<>1<>$i_handle<>$enctrip<>$encid<>$pmfile<>$i_trip<><>1<>1<>1<>\n);
open(BASE_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");
print BASE_OUT $line_base;
close(BASE_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_base.cgi");

# カテゴリファイル作成
my $line_category = qq(未分類<>1<>\n);
open(CATEGORY_OUT,">${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");
print CATEGORY_OUT $line_category;
close(CATEGORY_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/${pmfile}_cate.cgi");

# 未分類ファイル作成
my $line_ocm = qq(1<>未分類<>\n);
open(OCM_OUT,">${int_dir}_one/_idone/${pmfile}/1_ocm.cgi");
print OCM_OUT $line_ocm;
close(OCM_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/1_ocm.cgi");

# 全カテゴリファイル作成
my $line_allcomment = qq(1<><>\n);
open(ALLCOMMENT_OUT,">${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");
print ALLCOMMENT_OUT $line_allcomment;
close(ALLCOMMENT_OUT);
Mebius::Chmod(undef,"${int_dir}_one/_idone/${pmfile}/all_ocm.cgi");

# 新規メンバーファイルを開く
my $line_newcomer = qq($i_handle<>$pmfile<>\n);
open(NEWCOMER_IN,"${int_dir}_one/newcomer.cgi");
while(<NEWCOMER_IN>){
$i_newcomer++;
if($i_newcomer >= $max_comer){ last; }
$line_newcomer .= $_;
}
close(NEWCOMER_IN);

# 新規メンバーファイルを書き込む
open(NEWCOMER_OUT,">${int_dir}_one/newcomer.cgi");
print NEWCOMER_OUT $line_newcomer;
close(NEWCOMER_OUT);
Mebius::Chmod(undef,"${int_dir}_one/newcomer.cgi");

# ロック解除
&unlock("${pmfile}ONE") if $lockkey;

# HTML
my $print = qq(
新規登録が完了しました。
<a href="$script?mode=view-$pmfile-all-1">→マイログへ</a>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;

