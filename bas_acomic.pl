
# 設定
$title = "４コマ漫画";

# 広告
$ads1 = qq(
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* ４コマ漫画 */
google_ad_slot = "5641356314";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);

sub start{


# 汚染チェック
$in{'no'} = $mode;
$in{'no'} =~ s/\D//g;

# ファイル定義
$file = "../pct/acomic/comic$in{'no'}.GIF";

# CSS定義
$css_text .= qq(
.navi1{word-spacing:1em;margin:0em 0em 1em 0em;}
.navi2{word-spacing:1em;margin:0.5em 0em 0em 0em;}
.body1{text-align:center;}
.img{border-style:none;}
);

# タイトル定義
$sub_title = qq(４コマ漫画 - $in{'no'});
$head_link3 = qq( &gt; 作品$in{'no'});


# 画像が存在しない場合
unless(-e $file){ &error("ファイルが存在しません。"); };

# ナビゲーションリンク
my $before = $in{'no'} - 1;
$before_link = qq(<a href="$before.html">←前のマンガ</a>);
my $next = $in{'no'} + 1;
$next_link = qq(<a href="$next.html">次のマンガ→</a>);
my $top_link = qq(<a href="/">ＴＯＰページ</a>);
my $back_link = qq(<a href="/_acm/">掲示板へ</a>);
my $img_link = qq(<a href="$file">画像のみ</a>);
my $form_link = qq(<a href="http://aurasoul.mb2.jp/etc/mail.html">ご連絡</a>);

# HTML
my $print = <<"EOM";
<div class="navi1">$before_link $top_link $back_link $form_link $img_link $next_link</div>
<div class="ads1">$ads1<br><br></div>
<div class="comic"><img src="$file" alt="４コマ漫画 - $in{'no'}" class="img"><br></div>
<div class="ads1"><br>$ads1</div>
<div class="navi2">$before_link $top_link $back_link $form_link $img_link $next_link</div>
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
