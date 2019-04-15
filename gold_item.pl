
# 宣言
package Mebius::Goldcenter;
use strict;

#-----------------------------------------------------------
# モード振り分け（２）
#-----------------------------------------------------------
sub item{

# 宣言
my($script_mode,$gold_url,$title) = &init();

# タイトル定義
$main::sub_title = "アイテムショップ | $title";
$main::head_link3 = qq( &gt; <a href="item.html">アイテムショップ</a> );

# モード振り分け
if($main::submode2 eq ""){ &index_item(); }
else{ main::error("ページが存在しません。"); }

}

#-----------------------------------------------------------
# アイテムショップインデックス
#-----------------------------------------------------------
sub index_item{

# 宣言
my($type) = @_;
my($script_mode,$gold_url,$title) = &init();

# タイトル定義
$main::head_link3 = qq( &gt; アイテムショップ );

# HTML
my $print = qq(<h1>アイテムショップ - $title</h1>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
