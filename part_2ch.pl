#-----------------------------------------------------------
# ２ちゃんねるからのリンク
#-----------------------------------------------------------
sub from_2ch{

my($dlink,$indlink);
our($time,%in);

($dlink) = &Mebius::Encode("",$time);
($indlink) = &Mebius::Decode($in{'dlink'});

if($time < $in{'dlink'} + 3*60 && $in{'dlink'} < $time){ return; }

&Mebius::AccessLog("","From-enemy-site","URL: $ENV{'HTTP_REFERER'}");

print"Content-type:text/html\n\n";

print qq(
<html lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis">
<meta http-equiv="content-style-type" content="text/css">
<style type="text/css">
<!--
body{line-height:1.4em;}
-->
</style>
<title>
リンク
</title>
</head>
<body lang="ja">
<div class="body1">外部サイトよりお越しの方へ。<br><br>

本サイトでは、投稿マナーを守ってご利用ください。<br>
大変恐縮ではございますが、以下のような行為はご遠慮いただくようお願い\申\し上げます。<br><br>

<ul>
<li>アクセス攻撃をなさること。また、サーバーに負担をかける行為をなさること。</li>
<li>文字を羅列をしたり、ＡＡ（アスキーアート）の投稿なさること。</li>
<li>大人数でお越しになり、特定の場所に対して、一斉にお書き込みになること。<strong style="color:#f00;">（普段からのユーザー様にとっては、とつぜん大人数がお越しになることだけで、大変な不安を抱かれる場合がございます）</strong></li>
<li>お仲間を募り、特定の対象（掲示板、記事、ユーザー様など）に対して攻撃、論破、突撃などをおはかりになること。</li>
<li>「縦書き」「斜め書き」などのパズルを使って、暗にルール違反をなさること。</li>
<li>過剰なバッシングや、人を傷つける行為、不快にする行為をなさろうとすること。</li>
<li>例えばコマンドプロントで全ファイルを消去するなど、など危険なコマンドや、危険な\ソ\フ\トなどをご紹介になること。</li>
<li>他ユーザー様へを性的な対象として扱ったり、つきまといをなさること。また、明に暗に卑猥な投稿をなさること。</li>
<li>その他、既存ユーザー様の迷惑となる行為をなさること。</li>
<li>具体的に決められたルールの網目を見つけて、新しい迷惑行為をお考えになり、実行なさること。</li>
</ul>

違反行為や、他ユーザー様の迷惑となる行為があった場合、<br>
予\告なしに「削除」「投稿制限「プロバイダ連絡」、またその他の処置をとらせていただく場合がございます。<br><br>

<a href="./?dlink=$dlink">Go</a>
</div></body></html>
);

exit;

}

1;

