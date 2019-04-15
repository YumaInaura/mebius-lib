

# アカウントの最大表示数
my $max_aclist = 30;

# 局所化
my($new_link,$line_new,$i_line);

# ヘッダリンク
$head_link2 = qq( &gt; $title);

# CSS定義
$css_text .= qq(
.navi{font-size:90%;word-spacing:0.3em;padding:0.5em;background-color:#fcc;}
.account_list{line-height:1.5em;word-spacing:1em;padding-left:0.5em;}
);


# 基本ファイルを開く
if($idcheck){ &base_open($pmfile); }

# Cookieがない場合
if(!$cookie){  $new_link = qq( ＊この環境では新規参加できません。); }
# ログインしていない場合
elsif(!$idcheck){ $new_link = qq(
<h2>メンバーログイン</h2>
参加するには、ログイン(<a href="newform.html">または新規登録</a>)してください。<a href="$auth_url">メビリンＳＮＳ</a>と共通のアカウントです。<br><br>
<form action="$auth_url" method="post"$sikibetu>
<div><table>
<tr>
<td class="nowrap">アカウント名</td><td>
<input type="text" name="authid" value="" class="putid"$maxlengthac>
( 例： mickjagger )</td>
</tr>
<tr>
<td class="nowrap">パスワード</td>
<td><input type="password" name="passwd1" value="" maxlength="8">
(例： Adfk432d )</td>
</tr>
<tr><td></td><td>
<input type="submit" value="ログインする">
<input type="hidden" name="mode" value="login">
<input type="hidden" name="back" value="one">
</td></tr>
</table></div>
</form>


); }
# アカウント作成済みの場合
elsif($key_base eq "1"){ $new_link = qq(<br>　<a href="$script?mode=view-$pmfile-all-1">→あなた($name_base)のマイログはこちらです</a>); }
# アカウント未作成の場合
else{ $new_link = qq(<br>　<a href="$script?mode=start">→こちらから”$title”に参加できます。</a>); }

# ナビゲーションリンク
my $navi_link = qq(<div class="navi">他のサイト： <a href="http://aurasoul.mb2.jp/">メビリン通常版</a> <a href="http://mb2.jp/">メビリン娯楽版</a> <a href="$auth_url">メビリンＳＮＳ</a></div><br>);

# 新着コメントファイルを開く
open(NEW_COMMENT_IN,"${int_dir}_one/new_comment.cgi");
while(<NEW_COMMENT_IN>){
if($i_line > 10){ next; }
my($key,$comment,$date,$account,$num,$category,$name) = split(/<>/,$_);
if($key eq "1"){ $i_line++; $line_new .= qq(<li>$comment ( <a href="view-$account-$num-1.html">$category</a> ) by <a href="view-$account-all-1.html">$name</a>); }
}
close(NEW_COMMENT_IN);
$line_new = qq(<h2>最近の登録 (公式カテゴリのみ)</h2><ul>$line_new</ul><br><a href="vc-all-1.html">→全ての登録を見る</a>);

# 新規メンバーファイルを開く
open(NEWCOMER_IN,"${int_dir}_one/newcomer.cgi");
my($i_newcomer);
while(<NEWCOMER_IN>){
$i_newcomer++;
my($name,$account) = split(/<>/,$_);
$line_newcomer .= qq( <a href="view-$account-all-1.html">$name</a>);
if($i_newcomer >= $max_aclist){ last; }

}
close(NEWCOMER_IN);
$line_newcomer = qq(<h2>最近の参加者</h2><div class="account_list">$line_newcomer</div><br><a href="va-all-1.html">→全ての参加者を見る</a>);

# HTML
my $print = qq(
$navi_link
<h1>$title</h1>
カテゴリを作り、１行ずつ文章を書くことが出来るツールです。<br>
メモ、ライフログ、教訓の置き場、思考の整理場などとしてご利用ください (<a href="${guide_url}%A5%DE%A5%A4%A5%ED%A5%B0">→もっと詳しく</a>)。<br>
$new_link
$line_newcomer
$line_new
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

1;
