use strict;

#-----------------------------------------------------------
# 金貨センター
#-----------------------------------------------------------
sub main_gold{

# 宣言
our($title) = ("金貨センター");
our($submode2);


# モード振り分け
if($submode2 eq "index"){ &main_gold_top(); }
else{ &error("ページが存在しません。"); }
}


#-----------------------------------------------------------
# 金貨センタートップ
#-----------------------------------------------------------
sub main_gold_top{

# 宣言
my($guide);
our($title,$cusegold,$cspendgold);
our($xclose,$cgold,$callsave_flag);

&set_cookie();

# ヘッダ
&header();

# 説明
$guide = qq(アカウントにログインしていたり、一部の携帯電話では、金貨センターが利用できます。);
if($callsave_flag){ $guide .= qq(<br$xclose>いまのあなたは、金貨センターを利用<strong class="red">できます。</strong>); }
else{ $guide .= qq(<br$xclose>いまのあなたは、金貨センターを利用<strong class="red">できません。</strong>); }

# HTML
print qq(
<div class="body1">
<h1>$title</h1>
<h2>説明</h2>
$guide
<h2>メニュー</h2>
$callsave_flag
金貨： $cgold<br$xclose>
残り金貨： $cusegold
</div>
);

# フッタ
&footer;

exit;


}


1;

