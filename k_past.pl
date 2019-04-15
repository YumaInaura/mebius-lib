
package main;

#-----------------------------------------------------------
# 掲示板 携帯版の過去ログ
#-----------------------------------------------------------
sub bbs_view_past_mobile{

local($num,$sub,$res,$nam,$date,$na2,$key,$alarm,$i,$data,$top,$count);
my($file,$print);

# 携帯フラグを立てる
$kflag = 1;

# 過去ログ用に変数（引数）を変更
my $p = $submode2;

$on_kscript = qq(<a href="./">板</a>);

# タイトル定義
$sub_title = "$title 過去ログ";


$print .= <<"EOM";
<a name="up" id="up"></a><a href="#me">▽</a><a href=\"#dw\">▼</a>$new_rgt<a href="kfind.html">索</a>$on_kscript<a href="/">戸</a>
<hr$xclose>$title 過去ログ<hr$xclose>
EOM

$print .= qq(<a name="me" id="me"></a>);

if ($p eq "") { $p=0; }
$i=0;

# ファイル読み込み
open(IN,"<$pastfile") || &error("過去ログメニューが開けません");
$top = <IN>;
my($newnum,$none) = split(/<>/,$top);

# 親記事数認識、ページ繰り越しリンク数の調整
if($newnum < $i_max){$i_max = $newnum;}

$time = time;

while (<IN>) {
$i++;
next if ($i < $p + 1);
last if ($i > $p + $menu1);

my($num,$sub,$res,$nam,$date,$na2,$key) = split(/<>/);

$line .= "$mark<a href=\"$num.html\">$sub($res)</a><br$xclose>\n";
}
close(IN);

$print .= $line;

$print .= qq(<hr$xclose><a href="#me">△</a><a href="#up">▲</a>$new_rgt<a href="kfind.html">索</a>$on_kscript<a href="/">戸</a><hr$xclose><a name="dw" id="dw"></a>);

# ページリンク

my $next = $p + $menu1;
my $before = $p - $menu1;

$print .= qq(<a href="./">現</a>\n);

if($p >= $menu1){
$print .= qq(<a href="kpt-$before.html">←</a>\n);
}

$page = $i_max / $menu1;
$mile = 1;
while ($mile < $page + 1){
$mine = ($mile - 1) * $menu1;
if ($p == $mine) { $print .= "$mile\n"; }
else { $print .= "<a href=\"kpt-$mine.html\">$mile</a>\n"; }
$mile++; }

if($line){
$print .= qq(<a href="kpt-$next.html">→</a>\n);
}

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;
