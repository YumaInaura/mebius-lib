use Mebius::Export;

#-----------------------------------------------------------
# 携帯版エラー
#-----------------------------------------------------------
sub do_kerror{

# 宣言
my($error,$code) = @_;
our($mobile_error_done,$no_headerset,$headflag,$status_flag);

	# コード自動変換
	g_shift_jis($error);

# クッキーの重複セットを回避
$no_headerset = 1;

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }

	# 二重処理を禁止
	if($mobile_error_done){
		print "Content-type:text/html\n\n";
		print "error double";
		exit;
	}
	$mobile_error_done = 1;

# ステータスコード
if(!$headflag && !$status_flag){
if($k_access || $code eq "none"){}
elsif($code){ print "Status: $code\n"; }
else{ print "Status: 404 NotFound\n"; }
$status_flag = 1;
}

# タイトル定義
$sub_title = "エラー";

# 戻り先
if($in{'no'} && $nowfile){ $kback_link = "$in{'no'}.html"; }

# 携帯アイテムを取得
&kget_items();

# HTML
my $print = qq(エラー： <br$xclose>$error $code<br$xclose>);

# POST内容をフック
my $comment = $in{'comment'};
$comment =~ s/<br>/<br$xclose>/g;
if($in{'comment'}){ print qq(<hr$xclose>本文：<br$xclose>$comment); }

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

1;
